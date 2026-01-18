const mongoose = require('mongoose');

const provinceSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        unique: true
    },
    code: {
        type: String,
        required: true,
        unique: true
    },
    region: {
        type: String,
        required: true,
        enum: ['north', 'central', 'south']
    },
    schedule: [{
        type: Number, // 0 = Sunday, 1 = Monday, ...
        required: true
    }],
    crawlUrl: String
});

module.exports = mongoose.model('Province', provinceSchema);
