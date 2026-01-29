module Answers
  class AnswerService
    def self.aspects_answer_merger(answer)
      user_answers = {}
      if answer.present?
        user_answers = user_answers.merge **answer.cg_answers, **answer.be_answers, **answer.rm_answers, **answer.td_answers,
                        **answer.hr_answers, **answer.hc_answers, **answer.em_answers, **answer.sc_answers,
                        **answer.bd_answers, **answer.pr_answers, **answer.ohs_answers, **answer.csr_answers
      end
      return user_answers
    end
    
    def self.previous_answer_merger(existing_answer, aspect_name, user_answers)
      previousAnswer = existing_answer.send(aspect_name.to_sym)
      JSON.parse(user_answers).each do |key, value|
        if previousAnswer.key?(key)
          previousAnswer[key] = value
        else
          previousAnswer[key] = value
        end
      end
      return previousAnswer
    end

    def self.files_fetch(company_user_id, category_id, user_type)
      attachments = Attachment.find_by(user_id: company_user_id, category_id: category_id, user_type: user_type)&.files
      attachmentHtml = ""
      if attachments.present?
        attachments.each_with_index do |attachment, attachment_index|
          attachmentType = attachment.blob.content_type.split('/')[0]
          attachmentSrc = if attachmentType == 'image'
                            'image.png'
                          elsif attachmentType == 'video'
                            'video.png'
                          else
                            'file.png'
                          end
          attachmentHtml += "<div class='col-md-3'>
                             <button type='button' class='btn-close file-remove' id='category#{category_id}files-#{attachment_index}' aria-label='Close' data-file='#{attachment.blob.filename}'></button>
                             <a href='#{Rails.application.routes.url_helpers.rails_blob_path(attachment.blob, disposition: 'attachment', host: ENV['APPLICATION_HOST'])}'>
                             <img class='img-responsive img-thumbnail file-logo' src='/assets/#{attachmentSrc}'
                             title='#{attachment.blob.filename}'></a><p>#{attachment.filename}</p>
                           </div>"
        end
      end
      attachmentHtml
    end

    def self.add_files(company_user_id, category_id, user_type, files)
      attachments_exists = Attachment.find_by(user_id: company_user_id, category_id: category_id, user_type: user_type)

      if attachments_exists.present?
        files.each do |file|
          attachments_exists.files.attach(file)
        end
      else
        Attachment.create(user_id: company_user_id, category_id: category_id, files: files, user_type: user_type)
      end
    end

    def self.peerbenchmark_answer_merger(answer)
      user_answers = {}
      if answer.present?
          user_answers = user_answers.merge(answer.user_answers.is_a?(Hash) ? answer.user_answers : {})
      end
      return user_answers
    end

    def self.datacollection_answer_merger(answer)
      user_answers = {}
      if answer.present?
          user_answers = user_answers.merge(answer.user_answers.is_a?(Hash) ? answer.user_answers : {})
      end
      return user_answers
    end
    
    def self.remove_file(company_user_id, category_id, user_type, file_name)
      attachments_exists = Attachment.find_by(user_id: company_user_id, category_id: category_id, user_type: user_type)

      if attachments_exists.present?
        file = attachments_exists.files.blobs.find_by(filename: file_name)
        attachments_exists.files.find_by(blob_id: file.id).purge if file
      end
    end
    
  end
end