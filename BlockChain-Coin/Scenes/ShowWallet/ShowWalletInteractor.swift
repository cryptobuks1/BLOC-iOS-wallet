//
//  ShowWalletInteractor.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 14/02/2018.
//  Copyright © 2018 BlockChain-Coin.net. All rights reserved.
//

import Foundation

protocol ShowWalletBusinessLogic {
    var presenter: ShowWalletPresentationLogic? { get set }
    
    func fetchBalance(address: String)
}

class ShowWalletInteractor: ShowWalletBusinessLogic {
    var presenter: ShowWalletPresentationLogic?
    
    let walletWorker = WalletWorker(store: WalletRPC())
    
    func fetchBalance(address: String) {
        presenter?.handleShowBalancesLoading()
        
        walletWorker.getBalance(address: address) { [weak self] result in
            switch result {
            case .success(let balances):
                self?.presenter?.handleShowBalances(balances: balances)
            case .failure(let error):
                self?.presenter?.handleShowBalancesError(error: error)
            }
        }
    }
}

