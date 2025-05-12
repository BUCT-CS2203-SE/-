/**
 * 文物评论控制器
 */
const db = require("../models");
const { RelicComment, User, Artifact } = db;
const { Op } = require("sequelize");

// 添加评论
exports.create = async (req, res) => {
    try {
        // 验证请求
        if (!req.body.relic_id || !req.body.user_id || !req.body.comment) {
            return res.status(400).send({
                message: "文物ID、用户ID和评论内容不能为空！"
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

        const now = new Date();

        // 创建评论对象
        const comment = {
            relic_id: parseInt(req.body.relic_id),
            user_id: req.body.user_id,
            comment: req.body.comment,
            comment_time: now
        };

        // 保存到数据库
        const data = await RelicComment.create(comment);

        res.status(201).send({
            message: "评论添加成功",
            data: data
        });
    } catch (err) {
        res.status(500).send({
            message: err.message || "添加评论时发生错误。"
        });
    }
};

// 获取文物评论
exports.getComments = async (req, res) => {
    try {
        const relicId = req.params.id;

        const comments = await RelicComment.findAll({
            where: { relic_id: relicId },
            include: [{
                model: User,
                as: 'commentUser'
            }],
            order: [['comment_time', 'DESC']]
        });

        res.send(comments);
    } catch (err) {
        res.status(500).send({
            message: err.message || "获取评论时发生错误。"
        });
    }
};

// 获取用户评论
exports.getUserComments = async (req, res) => {
    try {
        const userId = req.params.id;

        const comments = await RelicComment.findAll({
            where: { user_id: userId },
            attributes: ['relic_comment_id', 'relic_id', 'user_id', 'comment', 'comment_time'],
            order: [['comment_time', 'DESC']]
        });

        res.send(comments);
    } catch (err) {
        res.status(500).send({
            message: err.message || "获取用户评论时发生错误。"
        });
    }
};

// 删除评论
exports.delete = async (req, res) => {
    try {
        const commentId = req.params.id;

        const num = await RelicComment.destroy({
            where: { relic_comment_id: commentId }
        });

        if (num == 1) {
            res.send({
                message: "评论删除成功！"
            });
        } else {
            res.send({
                message: `未找到ID为 ${commentId} 的评论。`
            });
        }
    } catch (err) {
        res.status(500).send({
            message: err.message || "删除评论时发生错误。"
        });
    }
}; 