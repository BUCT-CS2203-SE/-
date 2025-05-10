/**
 * 文物控制器
 */
const db = require("../models");
const Artifact = db.artifacts;
const Comment = db.comments;
const { Op } = db.Sequelize;

// 创建并保存新文物
exports.create = async (req, res) => {
    try {
        // 验证请求
        if (!req.body.name) {
            return res.status(400).send({
                message: "文物名称不能为空！"
            });
        }

        // 创建文物对象
        const artifact = {
            name: req.body.name,
            type: req.body.type || 7,
            era: req.body.era,
            museum: req.body.museum,
            description: req.body.description,
            spare_id: req.body.spare_id || 0
        };

        // 保存到数据库
        const data = await Artifact.create(artifact);
        res.send(data);
    } catch (err) {
        res.status(500).send({
            message: err.message || "创建文物时发生错误。"
        });
    }
};

// 获取所有文物（带分页和筛选）
exports.findAll = async (req, res) => {
    try {
        const { type, page = 1, pageSize = 10 } = req.query;
        const offset = (page - 1) * pageSize;
        const limit = parseInt(pageSize);

        const condition = type ? { type: type } : {};

        const { count, rows } = await Artifact.findAndCountAll({
            where: condition,
            offset: offset,
            limit: limit
        });

        res.send({
            artifacts: rows,
            totalCount: count,
            currentPage: parseInt(page),
            totalPages: Math.ceil(count / limit)
        });
    } catch (err) {
        res.status(500).send({
            message: err.message || "获取文物列表时发生错误。"
        });
    }
};

// 获取单个文物详情
exports.findOne = async (req, res) => {
    try {
        const id = req.params.id;

        const data = await Artifact.findByPk(id);

        if (data) {
            res.send(data);
        } else {
            res.status(404).send({
                message: `未找到ID为 ${id} 的文物。`
            });
        }
    } catch (err) {
        res.status(500).send({
            message: `获取ID为 ${req.params.id} 的文物详情时发生错误。`
        });
    }
};

// 更新文物
exports.update = async (req, res) => {
    try {
        const id = req.params.id;

        const num = await Artifact.update(req.body, {
            where: { relic_id: id }
        });

        if (num == 1) {
            res.send({
                message: "文物信息更新成功。"
            });
        } else {
            res.send({
                message: `无法更新ID为 ${id} 的文物。可能文物不存在或请求体为空！`
            });
        }
    } catch (err) {
        res.status(500).send({
            message: `更新ID为 ${req.params.id} 的文物时发生错误。`
        });
    }
};

// 删除文物
exports.delete = async (req, res) => {
    try {
        const id = req.params.id;

        const num = await Artifact.destroy({
            where: { relic_id: id }
        });

        if (num == 1) {
            res.send({
                message: "文物删除成功！"
            });
        } else {
            res.send({
                message: `无法删除ID为 ${id} 的文物。可能文物不存在！`
            });
        }
    } catch (err) {
        res.status(500).send({
            message: `删除ID为 ${req.params.id} 的文物时发生错误。`
        });
    }
};

// 关键词搜索文物
exports.search = async (req, res) => {
    try {
        const { keyword } = req.query;

        if (!keyword) {
            return res.status(400).send({
                message: "搜索关键词不能为空！"
            });
        }

        const data = await Artifact.findAll({
            where: {
                [Op.or]: [
                    { name: { [Op.like]: `%${keyword}%` } },
                    { description: { [Op.like]: `%${keyword}%` } },
                    { museum: { [Op.like]: `%${keyword}%` } },
                    { era: { [Op.like]: `%${keyword}%` } }
                ]
            }
        });

        res.send(data);
    } catch (err) {
        res.status(500).send({
            message: err.message || "搜索文物时发生错误。"
        });
    }
};

// 获取文物评论
exports.getComments = async (req, res) => {
    try {
        const artifactId = req.params.id;

        // 通过关联查询方式获取评论
        const artifact = await Artifact.findByPk(artifactId, {
            include: [{
                model: Comment,
                as: 'commentList',
                order: [['createTimestamp', 'DESC']]
            }]
        });

        if (!artifact) {
            return res.status(404).send({
                message: `未找到ID为 ${artifactId} 的文物。`
            });
        }

        res.send(artifact.commentList || []);
    } catch (err) {
        res.status(500).send({
            message: err.message || `获取文物ID为 ${req.params.id} 的评论时发生错误。`
        });
    }
}; 