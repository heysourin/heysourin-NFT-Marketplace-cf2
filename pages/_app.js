import "../styles/globals.css";
import Link from "next/link";

function MyApp({ Component, pageProps }) {
  return (
    <div>
      <nav className="border-b p-6">
        <p className="text-2xl font-bold">Xenon NFT Market</p>
        <div className="flex mt-4">
          <Link href="/" className="mr-4 text-pink-500">
            Home
          </Link>
          <Link href="/create-item" className="mr-4 text-pink-500">
            Sell NFT
          </Link>
          <Link href="/my-assets" className="mr-4 text-pink-500">
            My NFTs
          </Link>
          <Link href="/creator-dashboard" className="mr-4 text-pink-500">
            Dashboard
          </Link>
        </div>
      </nav>
      <Component {...pageProps} />
    </div>
  );
}

export default MyApp;
