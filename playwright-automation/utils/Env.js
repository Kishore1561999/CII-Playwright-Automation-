class Env {
    static get BASE_URL() {
        return process.env.BASE_URL || 'https://devcii2.spritle.com/';
    }

    static get ADMIN_EMAIL() {
        return process.env.ADMIN_EMAIL || 'kishore.r+admin@spritle.com';
    }

    static get ADMIN_PASSWORD() {
        return process.env.ADMIN_PASSWORD || 'Spritle123@';
    }

    static get MANAGER_EMAIL() {
        return process.env.MANAGER_EMAIL || 'kishore.r+manager@spritle.com';
    }

    static get MANAGER_PASSWORD() {
        return process.env.MANAGER_PASSWORD || 'Spritle123@';
    }

    static get ANALYST_EMAIL() {
        return process.env.ANALYST_EMAIL || 'kishore.r+analyst@spritle.com';
    }

    static get ANALYST_PASSWORD() {
        return process.env.ANALYST_PASSWORD || 'Spritle123@';
    }
}

module.exports = Env;
