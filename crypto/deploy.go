package crypto

import (
	"context"
	"fmt"
	"math/big"

	"github.com/demola234/defiraise/gen"
	"github.com/demola234/defiraise/utils"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

func Deploy() (string, error) {
	configs, err := utils.LoadConfig("./../")
	if err != nil {
		return "", err
	}

	client, err := ethclient.Dial(configs.CryptoDeployURL)
	if err != nil {
		return "", err

	}
	defer client.Close()
	account := common.HexToAddress(configs.ContractAddress)

	nonce, err := client.PendingNonceAt(context.Background(), account)
	if err != nil {
		return "", err
	}

	gasPrice, err := client.SuggestGasPrice(context.Background())
	if err != nil {
		return "", err
	}

	chainID, err := client.NetworkID(context.Background())
	if err != nil {
		return "", err
	}

	key, err := crypto.HexToECDSA(configs.ContractPrivateKey)
	if err != nil {
		return "", err
	}

	auth, err := bind.NewKeyedTransactorWithChainID(key, chainID)
	if err != nil {
		return "", err
	}
	auth.GasPrice = gasPrice
	auth.GasLimit = uint64(3000000)
	auth.Nonce = big.NewInt(int64(nonce))

	hotel, ts, _, err := gen.DeployGen(auth, client)
	if err != nil {
		return "", err
	}

	fmt.Println("-----------------------------------")
	fmt.Println(hotel.Hex())
	fmt.Println(ts.Hash().Hex())
	fmt.Println("-----------------------------------")
	return hotel.Hex(), err
}
