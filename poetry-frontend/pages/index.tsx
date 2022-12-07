import styles from "../styles/Home.module.css";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount, usePrepareContractWrite, useContractWrite, useWaitForTransaction } from "wagmi";
import { useState } from "react";
//import { Contract } from "alchemy-sdk";
import Panel from "../components/panels";
import Section from "../layout/section";
import abi from "../utils/poetry.json";

interface CreatePoemVals {
  poemText: string;
  price: number;
}

export default function Home() {
  const [formData, setFormData] = useState<CreatePoemVals>({
    poemText: "",
    price: 0,
  } as CreatePoemVals);
  const [poemText, setPoemText] = useState("");
  const [price, setPrice] = useState(0);

  const contractAddress = "0x7eC3A87CcA0bac08514e698Bd503E43C5F175bce";
  const { address, isConnected } = useAccount();

  const { config } = usePrepareContractWrite({
    address: contractAddress,
    abi: abi.filter(method => method["name"] === "createPoem"),
    functionName: "createPoem",
    args: [poemText, price],
  })
  const { data, write } = useContractWrite(config);

  const { isLoading, isSuccess } = useWaitForTransaction({ hash: data?.hash });

  /* const createPoem = async (text, price) => {
*   const create = new Contract(contractAddress, abi, await useAccount().)
*     .createPoem;
*   console.log("Creating poem...");
*   const poemTxn = await create(text, price);
* };
 */
  const handleChange = (e: React.ChangeEvent) => {
    const { name, value } = e.target as HTMLInputElement;
    setFormData((fData) => ({
      ...fData,
      [name]: value,
    }));
  };

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    write?.()
    //createPoem(formData.text, formData.price);
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
            name="poemText"
            type="text"
            onChange={(e) => setPoemText(e.target.value)}
            value={poemText}
          />
          <input
            name="price"
            type="number"
            onChange={(e) => setPrice(e.target.value)}
            value={price}
          />
          <button>Create Poem</button>
        </form>
        {isLoading && (<p>Making a poem</p>)}
        {isSuccess && (<p>Made a poem!</p>)}
      </main>
    </div>
  );
}
