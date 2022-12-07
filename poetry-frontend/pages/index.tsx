import styles from "../styles/Home.module.css";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount, usePrepareContractWrite, useContractWrite, useWaitForTransaction } from "wagmi";
import { useState } from "react";
import Panel from "../components/panels";
import Section from "../layout/section";
import abi from "../utils/poetry.json";

interface CreatePoemVals {
  poemText: string;
  price: number;
}

const Home = (): JSX.Element => {
  const [formData, setFormData] = useState<CreatePoemVals>({
    poemText: "",
    price: 0,
  });

  const contractAddress = "0x7eC3A87CcA0bac08514e698Bd503E43C5F175bce";
  const { address, isConnected } = useAccount();

  const { config } = usePrepareContractWrite({
    address: contractAddress,
    abi: abi.filter(method => method["name"] === "createPoem"),
    functionName: "createPoem",
    args: [formData.poemText, formData.price],
  })
  const { data, write } = useContractWrite(config);

  const { isLoading, isSuccess } = useWaitForTransaction({ hash: data?.hash });

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
  };

  return (
    <div>
      <header className={styles.header_container}>
        <nav className={styles.navbar}>
          <a
            href="/"
            target={"_blank"}
          >Poetry Marketplace
          </a>
          <ConnectButton showBalance={false} />
        </nav>
        <div className={styles.logo_container}>
          <h1 className={styles.logo}>✍️</h1>
          <h1>Poetry Marketplace</h1>
          <h2>No free verse allowed</h2>
        </div>
      </header>
      <main className={styles.main}>
        <Section>
          <Panel>

            <form onSubmit={handleSubmit}>
              <input
                name="poemText"
                type="text"
                onChange={handleChange}
                value={formData.poemText}
              />
              <input
                name="price"
                type="number"
                onChange={handleChange}
                value={formData.price}
              />
              <button>Create Poem</button>
            </form>

          </Panel>
        </Section>
        {isLoading && (<p>Making a poem</p>)}
        {isSuccess && (<p>Made a poem!</p>)}
      </main>
    </div>
  );
}

export default Home;
