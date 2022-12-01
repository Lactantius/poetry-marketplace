import React from "react";
import { Network, Alchemy } from "alchemy-sdk";
import Home from "./components/Home";

import "./App.css";

const settings = {
  apiKey: "demo",
  //network: Network.MATIC_MAINNET, // Replace with your network.
  network: "localhost:8545",
};

const alchemy = new Alchemy(settings);

function App() {
  return (
    <div className="App">
      <Home />
    </div>
  );
}

export default App;
