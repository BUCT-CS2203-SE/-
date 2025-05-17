/**
 * 文物收藏控制器
 */
const db = require("../models");
const { RelicFavorite, User, Artifact } = db;
const { Op } = require("sequelize");

// 添加收藏
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

        // 检查是否已收藏
        const existingFavorite = await RelicFavorite.findOne({
            where: {
                user_id: req.body.user_id,
                relic_id: parseInt(req.body.relic_id)
            }
        });

        if (existingFavorite) {
            return res.status(400).send({
                message: "已经收藏过该文物！"
            });
        }

        // 创建收藏对象
        const favorite = {
            user_id: req.body.user_id,
            relic_id: parseInt(req.body.relic_id)
        };

        // 保存到数据库
        const data = await RelicFavorite.create(favorite);

        res.status(201).send({
            message: "收藏添加成功",
            data: data
        });
    } catch (err) {
        res.status(500).send({
            message: err.message || "添加收藏时发生错误。"
        });
    }
};

// 获取文物收藏
exports.getFavorites = async (req, res) => {
    try {
        const relicId = req.params.id;

        const favorites = await RelicFavorite.findAll({
            where: { relic_id: relicId },
            include: [{
                model: User,
                as: 'favoriteUser'
            }],
            order: [['fav_id', 'DESC']]
        });

        res.send(favorites);
    } catch (err) {
        res.status(500).send({
            message: err.message || "获取收藏时发生错误。"
        });
    }
};

// 获取用户收藏
exports.getUserFavorites = async (req, res) => {
    try {
        const userId = req.params.id;

        const favorites = await RelicFavorite.findAll({
            where: { user_id: userId },
            include: [{
                model: Artifact,
                as: 'relic',
                include: [{
                    model: db.ArtifactPhoto,
                    as: 'photos',
                    limit: 1, // 只获取第一张图片
                    order: [['photo_id', 'ASC']] // 按photo_id升序排序
                }]
            }],
            order: [['fav_id', 'DESC']]
        });

        // 转换响应数据格式，只保留photos数组中的图片URL
        const formattedFavorites = favorites.map(fav => ({
            fav_id: fav.fav_id,
            user_id: fav.user_id,
            relic_id: fav.relic_id,
            relic: {
                ...fav.relic.toJSON(),
                photos: fav.relic.photos || [] // 保留photos数组
            }
        }));

        res.send(formattedFavorites);
    } catch (err) {
        res.status(500).send({
            message: err.message || "获取用户收藏时发生错误。"
        });
    }
};

// 取消收藏
exports.delete = async (req, res) => {
    try {
        const { userId, relicId } = req.params;

        const num = await RelicFavorite.destroy({
            where: {
                user_id: userId,
                relic_id: parseInt(relicId)
            }
        });

        if (num == 1) {
            res.send({
                message: "取消收藏成功！"
            });
        } else {
            res.send({
                message: `未找到用户ID为 ${userId} 对文物ID为 ${relicId} 的收藏。`
            });
        }
    } catch (err) {
        res.status(500).send({
            message: err.message || "取消收藏时发生错误。"
        });
    }
};

// 判断用户是否收藏了某个文物
exports.isFavorite = async (req, res) => {
    try {
        const { userId, relicId } = req.params;
        const favorite = await RelicFavorite.findOne({
            where: {
                user_id: userId,
                relic_id: parseInt(relicId)
            }
        });
        res.send({ isFavorite: !!favorite });
    } catch (err) {
        res.status(500).send({
            message: err.message || "查询收藏状态时发生错误。"
        });
    }
}; 