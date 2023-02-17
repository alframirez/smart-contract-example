<template>
  <div class="conections-container">
    <!-- Init amount section -->
    <div class="amount-container">
      <label>Amount to pay *:</label>
      <input
        type="number"
        id="input_amount_id"
        v-model="input_amount"
        placeholder=""
        autofocus
        autocomplete="off"
      />
    </div>
    <!-- End amount section -->

    <!-- Init Wallet cards -->
    <div class="card-container">
      <!-- Init Bsc options -->
      <div class="card">
        <img
          class="image"
          src="https://cryptologos.cc/logos/bnb-bnb-logo.png?v=023"
        />

        <!-- Conect Button -->
        <button
          v-if="!binance_conected && bsc_wallet_exist"
          id="user_bsc_wallet_account"
          class="btn-conection bsc-conection mb-2"
          @click="binanceConnection()"
        >
          CONECT WALLET
        </button>

        <!-- Install wallet if it does not exist  -->
        <button
          v-if="!bsc_wallet_exist"
          class="btn-conection metamask-conection mb-2"
          @click="BscWalletDownload()"
        >
          INSTALL BSC WALLET
        </button>

        <!-- Process payment button -->
        <button
          v-if="binance_conected"
          id="user_bsc_wallet_account"
          class="btn-conection bsc-conection mb-2"
          @click="BinanceWalletPayment(input_amount)"
        >
          PROCESS PAYMENT
        </button>

        <!-- Address conected -->
        <span class="show_binance_account"></span>
      </div>
      <!--End Bsc options -->

      <!-- Init Metamask options -->
      <div class="card">
        <img
          class="image"
          src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/MetaMask_Fox.svg/512px-MetaMask_Fox.svg.png"
        />

        <!-- Conect Button -->
        <button
          v-if="!metamask_conected && metamask_exist"
          class="btn-conection metamask-conection mb-2"
          @click="walletConnect()"
        >
          CONECT WALLET
        </button>

        <!-- Install wallet if it does not exist  -->
        <button
          v-if="!metamask_exist"
          class="btn-conection metamask-conection"
          @click="metamaskDownload()"
        >
          INSTALL METAMASK
        </button>

        <!-- Process payment button -->
        <button
          v-if="metamask_conected"
          class="btn-conection metamask-conection"
          @click="webThreePayment(input_amount)"
        >
          PROCESS PAYMENT
        </button>

        <!-- Address conected -->
        <span class="show_metamask_account"></span>
      </div>
      <!-- End Metamask options -->
    </div>
    <!-- End Wallet cards -->
  </div>
</template>
<script>
import { ethers } from "ethers";
export default {
  // This prop is available in case of need send the amount from other component
  props: ["amount_to_pay"],
  emits: ["registerBNBTransfer"],

  components: {},
  data() {
    return {
      metamask_conected: false,
      show_metamask_account: null,
      metamask_account: null,
      binance_account: null,
      binance_conected: false,
      show_binance_account: null,
      input_number: null,
      amount: "",
      input_amount: Number(this.amount_to_pay)
        ? Number(this.amount_to_pay)
        : null,
      metamask_exist: null,
      bsc_wallet_exist: null,
      token_address: import.meta.env.VITE_TOKEN_ADDRESS,
      token_symbol: import.meta.env.VITE_TOKEN_SYMBOL,
      token_decimals: import.meta.env.VITE_TOKEN_DECIMALS,
      receiver_account: import.meta.env.VITE_RECEIVER_ACCOUNT,
      token_abi: import.meta.env.VITE_TOKEN_ABI,
    };
  },
  mounted() {
    // Add text and the symbol of the actual token to the placeholder of input amount
    document.getElementById("input_amount_id").placeholder =
      "Add your amount in " + this.token_symbol;

    this.bsc_wallet_exist = window.BinanceChain ? true : false;
    this.metamask_exist = window.ethereum ? true : false;

    // this.getBnbPrice();
    this.input_amount = Number(this.amount_to_pay)
      ? Number(this.amount_to_pay)
      : null;
    // Save the actual Metamask Wallet Address in case to exist
    this.metamask_account = window.ethereum.selectedAddress;
    this.show_metamask_account = document.querySelector(
      ".show_metamask_account"
    );
    this.bnbAddress();
    this.show_binance_account = document.querySelector(".show_binance_account");
    // this.binance_account = window.BinanceChain.selectedAddress;
  },
  methods: {
    // Connect a diferent Wallet to BSC Wallet
    async walletConnect() {
      if (window.ethereum) {
        await window.ethereum
          .request({ method: "eth_requestAccounts" })
          .then(() => {
            // Declarate values of network.
            let network_id = 97;
            let network = network_id.toString(16);
            let chain_id = "0x" + network;
            // Try to switch to network selected.
            try {
              window.ethereum.request({
                method: "wallet_switchEthereumChain",
                params: [{ chainId: chain_id }],
              });
            } catch (Error) {
              // This error code indicates that the chain has not been added to MetaMask.
              if (Error.code === 4902) {
                // Added the network selected to Metamask.
                window.ethereum.request({
                  method: "wallet_addEthereumChain",
                  params: [
                    {
                      chainId: chain_id,
                      chainName: "Smart Chain - Testnet",
                      rpcUrls: [
                        "https://data-seed-prebsc-1-s1.binance.org:8545/",
                      ],
                    },
                  ],
                });
              }
            }
          });
        // Save the actual Metamask Wallet Address
        this.metamask_account = await window.ethereum.selectedAddress;
        // Print the actual Metamask Wallet Address
        this.show_metamask_account.innerHTML =
          (await this.metamask_account.substr(0, 18)) + "...";

        this.metamask_conected = true;
      }
    },
    async binanceConnection() {
      if (window.BinanceChain) {
        window.BinanceChain.request({ method: "eth_requestAccounts" }).then(
          () => {
            let network_id = 97;
            let network = network_id.toString(16);
            let chain_id = "0x" + network;
            window.ethereum.request({
              method: "wallet_switchEthereumChain",
              params: [{ chainId: chain_id }],
            });
          }
        );
      }

      if (window.BinanceChain) {
        window.BinanceChain.request({ method: "eth_sign" });
        this.binance_conected = true;
      }
      let provider = new ethers.providers.Web3Provider(window.BinanceChain);
      let signer = provider.getSigner();
      this.binance_account = await signer.getAddress();
      this.show_binance_account = document.querySelector(
        ".show_binance_account"
      );
    },
    async bnbAddress() {
      let provider = new ethers.providers.Web3Provider(window.BinanceChain);
      let signer = provider.getSigner();
      this.binance_account = await signer.getAddress();
    },
    async webThreePayment(input_amount) {
      if (input_amount === 0 || input_amount === "" || input_amount === null) {
        // notification of unvalid amount
        this.$toast.show("You must enter a valid amount!", {
          type: "error",
          position: "top-right",
          dismissible: true,
          duration: 3000,
        });
      } else {
        // Add token contract information
        const tokenAddress = this.token_address;
        const tokenAbi = this.token_abi;
        // end token contract information

        // change from number to hex
        this.input_number = input_amount;
        this.input_number = this.input_number.toString();
        this.input_number = ethers.utils.parseEther(this.input_number);
        this.amount = this.input_number._hex;
        // end change from number to hex

        // get from address signer
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        // end get from address signer

        // contract creation
        const contract = new ethers.Contract(tokenAddress, tokenAbi, signer);
        // end contract creation
        // payment
        provider.getGasPrice().then((currentGasPrice) => {
          let gas_price = ethers.utils.hexlify(parseInt(currentGasPrice));
          console.log(`gas_price: ${gas_price}`);

          contract
            .transfer(this.receiver_account, this.amount)
            .then((transaction) => {
              console.log("Transaction:", transaction.hash);
              this.checkPay(transaction.hash.substr(0, 17), input_amount);
            })
            .catch((err) => {
              err.error.code === -32603
                ? alert("Fondo insuficiente en la Wallet seleccionada")
                : false;
            });
        });
        // end payment
      }
    },
    async BinanceWalletPayment(input_amount) {
      if (input_amount === 0 || input_amount === "" || input_amount === null) {
        // notification of unvalid amount
        this.$toast.show("You must enter a valid amount!", {
          type: "error",
          position: "top-right",
          dismissible: true,
          duration: 3000,
        });
      } else {
        // Add token contract information
        const tokenAddress = this.token_address;
        const tokenAbi = this.token_abi;
        // end token contract information

        // change from number to hex
        this.input_number = input_amount;
        this.input_number = this.input_number.toString();
        this.input_number = ethers.utils.parseEther(this.input_number);
        this.amount = this.input_number._hex;
        // end change from number to hex

        // get from address signer
        const provider = new ethers.providers.Web3Provider(window.BinanceChain);
        const signer = provider.getSigner();
        console.log("Account:", await signer.getAddress());
        // end get from address signer

        // contract creation
        const contract = new ethers.Contract(tokenAddress, tokenAbi, signer);
        // end contract creation

        // payment
        provider.getGasPrice().then((currentGasPrice) => {
          let gas_price = ethers.utils.hexlify(parseInt(currentGasPrice));
          console.log(`gas_price: ${gas_price}`);

          contract
            .transfer(this.receiver_account, this.amount)
            .then((transaction) => {
              console.log("Transaction:", transaction.hash);
              this.checkPay(transaction.hash.substr(0, 17), input_amount);
            })
            .catch((err) => {
              err.error.code === -32603
                ? alert("Fondo insuficiente en la Wallet seleccionada")
                : false;
            });
        });
        // end payment
      }
    },

    checkPay(hash, amount) {
      alert(
        "Thanks for your payment of " +
          amount +
          " " +
          this.token_symbol +
          "! your transaction hash is: " +
          hash
      );
      // clear input value after send transaction
      this.input_amount = "";
    },

    metamaskDownload() {
      if (!window.ethereum) {
        window.open("https://metamask.io/download/", "_blank");
      }
    },
    BscWalletDownload() {
      if (!window.BinanceChain) {
        window.open("https://www.binance.com/es/wallet-direct", "_blank");
      }
    },
    async getAddress() {
      console.log("privateKey:", window.ethereum);

      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      let address = await signer.getAddress();
      console.log("addre:", address);
    },
  },
  watch: {
    async metamask_account() {
      if (this.metamask_account && this.metamask_account !== "") {
        this.show_metamask_account.innerHTML =
          (await this.metamask_account.substr(0, 18)) + "...";
        this.metamask_conected = true;
      }
    },
    async binance_account() {
      if (this.binance_account && this.binance_account !== "") {
        this.show_binance_account.innerHTML =
          (await this.binance_account.substr(0, 18)) + "...";
        this.binance_conected = true;
      }
    },
  },
};
</script>
<style>
/*  */
.conections-container {
  background-color: white;
  border: 0.3rem solid;
  border-radius: 0.5rem;
  padding: 0.5rem;
  border-color: white;
}
/*  */
.amount-container {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  margin-bottom: 1rem;
}

input[type="number"] {
  width: 15rem;
  height: 2rem;
  border-radius: 0.3rem;
  border: 0.2rem solid;
  font-weight: 700;
  font-size: 1rem;
  font-family: "Roboto";
  color: black;
}
/*init hide input arrows */
input[type="number"]::-webkit-inner-spin-button,
input[type="number"]::-webkit-outer-spin-button {
  -webkit-appearance: none;
  margin: 0;
}
input[type="number"] {
  -moz-appearance: textfield;
}
/*end hide input arrows */

::placeholder {
  color: black;
  opacity: 1;
}
/* init of cards section */
.card-container {
  display: flex;
  justify-content: center;
  align-items: center;
}
.card {
  /* Add shadows to create the "card" effect */
  box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2);
  transition: 0.3s;
  border-radius: 0.5rem;
  padding-left: 0.5rem;
  padding-right: 0.5rem;
  padding-bottom: 0.5rem;
  margin-left: 0.5rem;
  margin-right: 0.5rem;

  display: flex;
  flex-direction: column;
  align-items: center;
}

/* On mouse-over, add a deeper shadow */
.card:hover {
  box-shadow: 0 8px 16px 0 rgba(0, 0, 0, 0.2);
}
.image {
  justify-content: center;
  align-items: center;
  width: 3.5rem;
  height: 3.5rem;
  margin-bottom: 1rem;
}
/* init of buttons section */
.metamask-conection {
  background-color: orange;
}
.metamask-conection:hover {
  cursor: pointer;
}
.bsc-conection {
  background-color: #ffcb1efb;
}
.bsc-conection:hover {
  cursor: pointer;
}
.btn-conection {
  color: white;
  height: 35px;
  border-style: none;
  border-radius: 0.3rem;
  font-weight: 700;
  font-size: 0.8rem;
  font-family: "Roboto";
  box-shadow: 1px 1px 10px -4px #838383;
}
/* end of buttons section */
/* end of cards section */
</style>
