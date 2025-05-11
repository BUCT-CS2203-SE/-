/**
 * 文物控制器
 */
const db = require("../models");
const { Artifact, ArtifactPhoto } = db;
const { Op } = require("sequelize");

// 创建文物
exports.create = async (req, res) => {
    try {
        // 创建文物基本信息
        const artifact = await Artifact.create({
            name: req.body.name,
            type: req.body.type,
            era: req.body.era,
            museum: req.body.museum,
            description: req.body.description,
            spare_id: req.body.spare_id || 0
        });

        // 如果有图片，创建图片记录
        if (req.body.photos && Array.isArray(req.body.photos)) {
            const photoPromises = req.body.photos.map(photoUrl => 
                ArtifactPhoto.create({
                    relic_id: artifact.relic_id,
                    photo_url: photoUrl
                })
            );
            await Promise.all(photoPromises);
        }

        // 返回创建的文物信息（包含图片）
        const createdArtifact = await Artifact.findByPk(artifact.relic_id, {
            include: [{
                model: ArtifactPhoto,
                as: 'photos'
            }]
        });

        res.status(201).json({
            message: "文物创建成功",
            data: createdArtifact
        });
    } catch (error) {
        console.error('创建文物失败:', error);
        res.status(500).json({
            message: "创建文物失败",
            error: error.message
        });
    }
};

// 获取所有文物
exports.findAll = async (req, res) => {
    try {
        const { type, keyword, page = 1, pageSize = 10 } = req.query;
        const offset = (page - 1) * pageSize;
        
        // 构建查询条件
        const where = {};
        if (type) {
            where.type = type;
        }
        if (keyword) {
            where[Op.or] = [
                { name: { [Op.like]: `%${keyword}%` } },
                { description: { [Op.like]: `%${keyword}%` } }
            ];
        }

        // 查询文物列表
        const { count, rows } = await Artifact.findAndCountAll({
            where,
            include: [{
                model: ArtifactPhoto,
                as: 'photos'
            }],
            limit: parseInt(pageSize),
            offset: parseInt(offset),
            order: [['relic_id', 'DESC']]
        });

        res.json({
            total: count,
            currentPage: parseInt(page),
            pageSize: parseInt(pageSize),
            data: rows
        });
    } catch (error) {
        console.error('获取文物列表失败:', error);
        res.status(500).json({
            message: "获取文物列表失败",
            error: error.message
        });
    }
};

// 获取所有文物（不分页）
exports.getAll = async (req, res) => {
    try {
        const artifacts = await Artifact.findAll({
            include: [{
                model: ArtifactPhoto,
                as: 'photos'
            }],
            order: [['relic_id', 'DESC']]
        });

        res.json({
            message: "获取文物列表成功",
            data: artifacts
        });
    } catch (error) {
        console.error('获取文物列表失败:', error);
        res.status(500).json({
            message: "获取文物列表失败",
            error: error.message
        });
    }
};

// 获取单个文物
exports.findOne = async (req, res) => {
    try {
        const artifact = await Artifact.findByPk(req.params.id, {
            include: [{
                model: ArtifactPhoto,
                as: 'photos'
            }]
        });

        if (!artifact) {
            return res.status(404).json({
                message: "未找到该文物"
            });
        }

        res.json(artifact);
    } catch (error) {
        console.error('获取文物详情失败:', error);
        res.status(500).json({
            message: "获取文物详情失败",
            error: error.message
        });
    }
};

// 更新文物
exports.update = async (req, res) => {
    try {
        const artifact = await Artifact.findByPk(req.params.id);
        if (!artifact) {
            return res.status(404).json({
                message: "未找到该文物"
            });
        }

        // 更新文物基本信息
        await artifact.update({
            name: req.body.name,
            type: req.body.type,
            era: req.body.era,
            museum: req.body.museum,
            description: req.body.description,
            spare_id: req.body.spare_id
        });

        // 如果提供了新的图片列表，更新图片
        if (req.body.photos && Array.isArray(req.body.photos)) {
            // 删除旧的图片记录
            await ArtifactPhoto.destroy({
                where: { relic_id: artifact.relic_id }
            });

            // 创建新的图片记录
            const photoPromises = req.body.photos.map(photoUrl => 
                ArtifactPhoto.create({
                    relic_id: artifact.relic_id,
                    photo_url: photoUrl
                })
            );
            await Promise.all(photoPromises);
        }

        // 返回更新后的文物信息
        const updatedArtifact = await Artifact.findByPk(artifact.relic_id, {
            include: [{
                model: ArtifactPhoto,
                as: 'photos'
            }]
        });

        res.json({
            message: "文物更新成功",
            data: updatedArtifact
        });
    } catch (error) {
        console.error('更新文物失败:', error);
        res.status(500).json({
            message: "更新文物失败",
            error: error.message
        });
    }
};

// 删除文物
exports.delete = async (req, res) => {
    try {
        const artifact = await Artifact.findByPk(req.params.id);
        if (!artifact) {
            return res.status(404).json({
                message: "未找到该文物"
            });
        }

        // 删除文物（由于设置了外键约束，相关的图片记录会自动删除）
        await artifact.destroy();

        res.json({
            message: "文物删除成功"
        });
    } catch (error) {
        console.error('删除文物失败:', error);
        res.status(500).json({
            message: "删除文物失败",
            error: error.message
        });
    }
};

// 获取文物图片
exports.getPhotos = async (req, res) => {
    try {
        const photos = await ArtifactPhoto.findAll({
            where: { relic_id: req.params.id }
        });

        res.json(photos);
    } catch (error) {
        console.error('获取文物图片失败:', error);
        res.status(500).json({
            message: "获取文物图片失败",
            error: error.message
        });
    }
};

// 添加文物图片
exports.addPhoto = async (req, res) => {
    try {
        const artifact = await Artifact.findByPk(req.params.id);
        if (!artifact) {
            return res.status(404).json({
                message: "未找到该文物"
            });
        }

        const photo = await ArtifactPhoto.create({
            relic_id: artifact.relic_id,
            photo_url: req.body.photo_url
        });

        res.status(201).json({
            message: "图片添加成功",
            data: photo
        });
    } catch (error) {
        console.error('添加文物图片失败:', error);
        res.status(500).json({
            message: "添加文物图片失败",
            error: error.message
        });
    }
};

// 删除文物图片
exports.deletePhoto = async (req, res) => {
    try {
        const photo = await ArtifactPhoto.findByPk(req.params.photoId);
        if (!photo) {
            return res.status(404).json({
                message: "未找到该图片"
            });
        }

        await photo.destroy();

        res.json({
            message: "图片删除成功"
        });
    } catch (error) {
        console.error('删除文物图片失败:', error);
        res.status(500).json({
            message: "删除文物图片失败",
            error: error.message
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
                model: db.Comment,
                as: 'comments',
                order: [['comment_time', 'DESC']]
            }]
        });

        if (!artifact) {
            return res.status(404).json({
                message: `未找到ID为 ${artifactId} 的文物。`
            });
        }

        res.json(artifact.comments || []);
    } catch (error) {
        console.error('获取文物评论失败:', error);
        res.status(500).json({
            message: "获取文物评论失败",
            error: error.message
        });
    }
}; 