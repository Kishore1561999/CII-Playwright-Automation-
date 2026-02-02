require "roo"

namespace :users do
  desc "Import users data from spreadsheet"

  task load_users_data: :environment do
    p "Importing users data from spreadsheet"
    begin
      data = Roo::Spreadsheet.open("lib/Users.xlsx")
      data.sheet('Users').each_with_index do |row, idx|
        next if idx == 0
        if row[2].present? && (!User.find_by(email: row[2]).present?)
          User.create!(first_name: row[0], last_name: row[1], email: row[2], mobile: (row[3] ? row[3].to_i : ""),
                       password: row[4], company_name: row[5], company_isin_number: row[6],
                       company_sector: row[7], company_description: row[8],
                       company_address_line1: row[9], company_address_line2: row[10], company_country: row[11],
                       company_state: row[12], company_city: row[13], company_zip: (row[14] ? row[14].to_i : ""),
                       primary_name: row[15], primary_email: row[16], primary_contact: (row[17] ? row[17].to_i : ""),
                       primary_designation: row[18], alternate_name: row[19], alternate_email: row[20],
                       alternate_contact: (row[21] ? row[21].to_i : ""), alternate_designation: row[22],
                       user_status: (row[23] ? (row[23] == "REGISTRATION_SUBMITTED" ? ApplicationRecord::REGISTRATION_SUBMITTED : (row[23] == "REGISTRATION_APPROVED" ? ApplicationRecord::REGISTRATION_APPROVED : "")) : ""),
                       role_id: Role.find_by(role_name: (row[24] ? (row[24] == "ADMIN" ? ApplicationRecord::ADMIN : (row[24] == "MANAGER" ? ApplicationRecord::MANAGER : (row[24] == "ANALYST" ? ApplicationRecord::ANALYST : (row[24] == "COMPANY_USER" ? ApplicationRecord::COMPANY_USER : "")))) : ""))&.id,
                       approved: row[25])
        end
      end
      p "Import users data Successfully Completed..."
    rescue
      p "Import users data failed, Enter Excel data properly!.."
    end
  end
end