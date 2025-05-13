/**
 * 数据库配置文件
 */
module.exports = {
    HOST: "101.43.234.152",
    USER: "SE2025",
    PASSWORD: "Cs22032025",
    DB: "se2025",
    dialect: "mysql",
    pool: {
        max: 5,
        min: 0,
        acquire: 30000,
        idle: 10000
    }
}; 