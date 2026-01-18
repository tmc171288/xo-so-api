require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const connectDB = require('./config/database');
const resultsRouter = require('./routes/results');
const initScheduledJobs = require('./jobs/dailyCrawl');
const LotteryResult = require('./models/LotteryResult');

// Connect to MongoDB
connectDB();

// Initialize Express app
const app = express();
const server = http.createServer(app);

// Configure Socket.IO with CORS
const io = socketIo(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/results', resultsRouter);

// Health Check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date(), ip: req.ip });
});

app.get('/', (req, res) => {
    res.json({
        message: 'Lottery API Service (Dockerized)',
        version: '2.0.0',
        docs: '/api/results/:region/latest'
    });
});

// Socket.IO Connection
io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);

    // Join room based on region
    socket.on('subscribe', (region) => {
        if (['north', 'central', 'south'].includes(region)) {
            socket.join(region);
            console.log(`Client ${socket.id} joined ${region}`);
        }
    });

    // Handle immediate request for latest result
    socket.on('get_live_results', async ({ region }) => {
        try {
            // Fetch latest from DB
            const result = await LotteryResult.findOne({ region }).sort({ date: -1 });
            if (result) {
                socket.emit('live_results', { region, results: [result] });
            }
        } catch (error) {
            console.error('Socket fetch error:', error);
        }
    });

    socket.on('disconnect', () => {
        console.log('Client disconnected:', socket.id);
    });
});

// Initialize Scheduled Jobs (Cron)
initScheduledJobs(io);

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📡 Socket.IO ready`);
    console.log(`📂 Environment: ${process.env.NODE_ENV}`);
});
