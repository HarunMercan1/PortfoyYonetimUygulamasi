const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// ROUTES
app.use("/api/users", require("./routes/users"));
app.use("/api/assets", require("./routes/assets"));
app.use("/api/types", require("./routes/assetTypes"));
app.use("/api/currencies", require("./routes/currencies"));
app.use("/api/transactions", require("./routes/transactions"));
app.use("/api/auth", require("./routes/auth"));
app.use("/api/stocks", require("./routes/stocks"));
app.use("/api/cryptos", require("./routes/cryptos"));
app.use("/api/commodities", require("./routes/commodities"));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Server ${PORT} portunda calisiyor...`));
