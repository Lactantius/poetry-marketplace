import styles from "../styles/Home.module.css";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";
import Panel from "../components/panels";
import Section from "../layout/section";
import alchemy from "../utils/alchemy";
import abi from "../utils/poetry.json";

export default function Home() {
	const contractAddress = "0x7eC3A87CcA0bac08514e698Bd503E43C5F175bce";
	const { address } = useAccount();

	const createPoem = async (text, price) => {
		const create = new alchemy.Contract(contractAddress, abi, address)
			.createPoem;
		console.log("Creating poem...");
		const poemTxn = await create((poemText = text), (price = price));
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
			</main>
		</div>
	);
}
