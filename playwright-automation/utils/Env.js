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
}

module.exports = Env;
