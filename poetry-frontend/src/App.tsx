import React from "react";
import { Network, Alchemy } from "alchemy-sdk";
import Home from "./components/Home";

import "./App.css";

const settings = {
  apiKey: process.env.REACT_APP_ALCHEMY_API_KEY,
  network: Network.MATIC_MUMBAI, // Replace with your network.
};

const alchemy = new Alchemy(settings);
//const provider = new ethers.providers.Web3Provider(window.ethereum);

function App() {
  return (
    <div className="App">
      <Home />
    </div>
  );
}

export default App;
