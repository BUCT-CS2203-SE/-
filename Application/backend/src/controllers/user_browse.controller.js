/**
 * 用户浏览历史控制器
 */
const db = require("../models");
const { UserBrowse, User, Artifact, ArtifactPhoto } = db;
const { Op } = require("sequelize");

// 添加浏览记录
exports.create = async (req, res) => {
    try {
        // 验证请求
        if (!req.body.relic_id || !req.body.user_id) {
            return res.status(400).send({
                message: "文物ID和用户ID不能为空！"
            });
        }

        // 检查文物和用户是否存在
        const artifact = await Artifact.findByPk(req.body.relic_id);
        const user = await User.findByPk(req.body.user_id);

        if (!artifact) {
            return res.status(404).send({
                message: `未找到ID为 ${req.body.relic_id} 的文物。`
            });
        }

        if (!user) {
            return res.status(404).send({
                message: `未找到ID为 ${req.body.user_id} 的用户。`
            });
        }

        // 创建浏览记录对象
        const browse = {
            user_id: req.body.user_id,
            relic_id: parseInt(req.body.relic_id),
            browse_time: new Date()
        };

        // 保存到数据库
        const data = await UserBrowse.create(browse);

        res.status(201).send({
            message: "浏览记录添加成功",
            data: data
        });
    } catch (err) {
        res.status(500).send({
            message: err.message || "添加浏览记录时发生错误。"
        });
    }
};

// 获取用户的浏览历史
exports.getUserBrowses = async (req, res) => {
    try {
        const userId = req.params.id;

        const browses = await UserBrowse.findAll({
            where: { user_id: userId },
            include: [{
                model: Artifact,
                as: 'relic',
                include: [{
                    model: ArtifactPhoto,
                    as: 'photos',
                    limit: 1, // 只获取第一张图片
                    order: [['photo_id', 'ASC']] // 按photo_id升序排序
                }]
            }],
            order: [['browse_time', 'DESC']] // 按浏览时间降序排序
        });

        // 转换响应数据格式
        const formattedBrowses = browses.map(browse => ({
            browse_id: browse.browse_id,
            user_id: browse.user_id,
            relic_id: browse.relic_id,
            browse_time: browse.browse_time,
            relic: browse.relic ? {
                ...browse.relic.toJSON(),
                photos: browse.relic.photos || []
            } : null
        }));

        res.send(formattedBrowses);
    } catch (err) {
        res.status(500).send({
            message: err.message || "获取用户浏览历史时发生错误。"
        });
    }
};

// 获取文物的浏览记录
exports.getRelicBrowses = async (req, res) => {
    try {
        const relicId = req.params.id;

        const browses = await UserBrowse.findAll({
            where: { relic_id: relicId },
            include: [{
                model: User,
                as: 'browseUser',
                attributes: ['user_id', 'nickname', 'img_url'] // 只返回需要的用户信息
            }],
            order: [['browse_time', 'DESC']]
        });

        res.send(browses);
    } catch (err) {
        res.status(500).send({
            message: err.message || "获取文物浏览记录时发生错误。"
        });
    }
};

// 删除浏览记录
exports.delete = async (req, res) => {
    try {
        const browseId = req.params.id;

        const num = await UserBrowse.destroy({
            where: { browse_id: browseId }
        });

        if (num == 1) {
            res.send({
                message: "浏览记录删除成功！"
            });
        } else {
            res.send({
                message: `未找到ID为 ${browseId} 的浏览记录。`
            });
        }
    } catch (err) {
        res.status(500).send({
            message: err.message || "删除浏览记录时发生错误。"
        });
    }
};

// 清空用户的浏览历史
exports.clearUserBrowses = async (req, res) => {
    try {
        const userId = req.params.id;

        const num = await UserBrowse.destroy({
            where: { user_id: userId }
        });

        res.send({
            message: `成功删除 ${num} 条浏览记录。`
        });
    } catch (err) {
        res.status(500).send({
            message: err.message || "清空浏览历史时发生错误。"
        });
    }
};

// 获取用户的最近浏览记录（限制数量）
exports.getRecentBrowses = async (req, res) => {
    try {
        const userId = req.params.id;
        const limit = parseInt(req.query.limit) || 10; // 默认返回最近10条记录

        const browses = await UserBrowse.findAll({
            where: { user_id: userId },
            include: [{
                model: Artifact,
                as: 'relic',
                include: [{
                    model: ArtifactPhoto,
                    as: 'photos',
                    limit: 1,
                    order: [['photo_id', 'ASC']]
                }]
            }],
            order: [['browse_time', 'DESC']],
            limit: limit
        });

        // 转换响应数据格式
        const formattedBrowses = browses.map(browse => ({
            browse_id: browse.browse_id,
            user_id: browse.user_id,
            relic_id: browse.relic_id,
            browse_time: browse.browse_time,
            relic: browse.relic ? {
                ...browse.relic.toJSON(),
                photos: browse.relic.photos || []
            } : null
        }));

        res.send(formattedBrowses);
    } catch (err) {
        res.status(500).send({
            message: err.message || "获取最近浏览记录时发生错误。"
        });
    }
}; 