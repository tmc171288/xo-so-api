const mongoose = require('mongoose');

const lotteryResultSchema = new mongoose.Schema({
    region: {
        type: String,
        required: true,
        enum: ['north', 'central', 'south']
    },
    province: {
        type: String,
        required: true
    },
    date: {
        type: String,
        required: true,
        index: true
    },
    drawTime: String,
    prizes: {
        special: String,
        first: [String],
        second: [String],
        third: [String],
        fourth: [String],
        fifth: [String],
        sixth: [String],
        seventh: [String],
        eighth: [String],
        special_code: [String] // For simplified North region view sometimes
    },
    isLive: {
        type: Boolean,
        default: false
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

// Compound index for fast lookups
lotteryResultSchema.index({ region: 1, date: 1 });
lotteryResultSchema.index({ province: 1, date: 1 });

// TTL Index - Automatically delete documents after 30 days
// 30 days * 24 hours * 60 minutes * 60 seconds = 2592000 seconds
lotteryResultSchema.index({ createdAt: 1 }, { expireAfterSeconds: 2592000 });

module.exports = mongoose.model('LotteryResult', lotteryResultSchema);
