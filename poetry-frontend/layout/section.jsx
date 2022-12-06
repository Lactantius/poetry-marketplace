import styles from "../styles/Section.module.css";

const Section = ({ children, title, description }) => {
	return (
		<div className={styles.section}>
			<div>
				{title && <h3>{title}</h3>}
				{description && <p>{description}</p>}
			</div>
			{children}
		</div>
	);
};

export default Section;
