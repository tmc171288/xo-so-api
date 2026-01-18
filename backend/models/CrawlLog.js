const mongoose = require('mongoose');

const crawlLogSchema = new mongoose.Schema({
    date: {
        type: Date,
        default: Date.now
    },
    status: {
        type: String,
        enum: ['success', 'failed', 'partial'],
        required: true
    },
    region: String,
    message: String,
    recordsProcessed: {
        type: Number,
        default: 0
    },
    durationMs: Number
});

// Auto delete logs after 7 days
crawlLogSchema.index({ date: 1 }, { expireAfterSeconds: 604800 });

module.exports = mongoose.model('CrawlLog', crawlLogSchema);
