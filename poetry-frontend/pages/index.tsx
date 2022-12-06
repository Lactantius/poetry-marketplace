import styles from "../styles/Home.module.css";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";
import { useState } from "react";
import Panel from "../components/panels";
import Section from "../layout/section";
import alchemy from "../utils/alchemy";
import abi from "../utils/poetry.json";

interface CreatePoemVals {
  text: string;
  price: number;
}

export default function Home() {
  const [formData, setFormData] = useState<CreatePoemVals>({
    text: "",
    price: 0,
  } as CreatePoemVals);

  const contractAddress = "0x7eC3A87CcA0bac08514e698Bd503E43C5F175bce";
  const { address } = useAccount();

  const createPoem = async (text, price) => {
    const create = new alchemy.Contract(contractAddress, abi, address)
      .createPoem;
    console.log("Creating poem...");
    const poemTxn = await create((poemText = text), (price = price));
  };

  const handleChange = (e: React.ChangeEvent) => {
    const { name, value } = e.target as HTMLInputElement;
    setFormData((fData) => ({
      ...fData,
      [name]: value,
    }));
  };

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    createPoem(formData.text, formData.price);
  };

  return (
    <div>
      <header className={styles.header_container}>
        <nav className={styles.navbar}>
          <a
            href="https://alchemy.com/?a=create-web3-dapp"
            target={"_blank"}
          >
            <img
              className={styles.alchemy_logo}
              src="/alchemy_logo.svg"
            ></img>
          </a>
          <ConnectButton showBalance={false} />
        </nav>
        <div className={styles.logo_container}>
          <h1 className={styles.logo}>🔮</h1>
          <h1>create-web3-dapp</h1>
          <a target={"_blank"} href="#" className={styles.docs_box}>
            Visit the documentation to get started
          </a>
        </div>
      </header>
      <main className={styles.main}>
        <Section>
          <Panel></Panel>
        </Section>
        <form onSubmit={handleSubmit}>
          <input
            name="text"
            type="text"
            onChange={handleChange}
            value={formData.text}
          />
          <input
            name="price"
            type="number"
            onChange={handleChange}
            value={formData.price}
          />
          <button>Create Poem</button>
        </form>
      </main>
    </div>
  );
}
