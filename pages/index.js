import Head from "next/head";
import Image from "next/image";
import styles from "../styles/Home.module.css";
import axios from "axios";
import web3modal from "web3modal";
import ethers from "ethers";
import { useState, useEffect } from "react";
import { nftaddress,nftmarketaddress} from "../configr";


export default function Home() {
  return <div className={styles.container}>Hello</div>;
}
