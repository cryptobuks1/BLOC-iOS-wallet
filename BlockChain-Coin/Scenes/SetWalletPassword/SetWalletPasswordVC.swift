//  
//  SetWalletPasswordVC.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 15/03/2018.
//  Copyright © 2018 BlockChain-Coin.net. All rights reserved.
//

import UIKit
import RxSwift

protocol SetWalletPasswordDisplayLogic: class {
    func handleUpdate(viewModel: SetWalletPasswordViewModel)
}

class SetWalletPasswordVC: ViewController, SetWalletPasswordDisplayLogic {
    
    let formView = ScrollableStackView()
    let formFields = SetWalletFormViews()
    let toolbar = FormToolbar()
    
    let router: SetWalletPasswordRoutingLogic
    let interactor: SetWalletPasswordBusinessLogic
    
    fileprivate let disposeBag = DisposeBag()

    // MARK: - View lifecycle
    
    init() {
        let interactor = SetWalletPasswordInteractor()
        let presenter = SetWalletPasswordPresenter()
        let router = SetWalletPasswordRouter()
        
        self.router = router
        self.interactor = interactor
        
        super.init(nibName: nil, bundle: nil)
        
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }
    
    init(router: SetWalletPasswordRoutingLogic, interactor: SetWalletPasswordBusinessLogic) {
        self.router = router
        self.interactor = interactor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        formFields.passwordField.textField.becomeFirstResponder()
    }

    // MARK: - Configuration
    
    func configure() {
        view.backgroundColor = .clear
        
        view.addSubview(formView)
        
        formView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        
        // Form
        
        formFields.orderedViews.forEach(formView.stackView.addArrangedSubview)
        
        [ formFields.passwordField, formFields.passwordBisField ].forEach { field in
            field.textField.inputAccessoryView = toolbar
            field.didBecomeFirstResponder = toolbar.updateArrows
            field.didTapReturn = toolbar.nextTapped
        }
        
        formFields.passwordBisField.didTapReturn = nextTapped
        
        toolbar.responders = [ formFields.passwordField.textField,
                               formFields.passwordBisField.textField ]
        
        formFields.nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        Observable.combineLatest(formFields.passwordField.rx_text, formFields.passwordBisField.rx_text).subscribe(onNext: { [weak self] password, passwordBis in
            let form = SetWalletPasswordForm(password: password, passwordBis: passwordBis)
            
            log.info(form)
            
            self?.interactor.validateForm(request: SetWalletPasswordRequest(form: form))
        }).disposed(by: disposeBag)
        
        // Navigation Bar
        
        let titleView = TitleView(title: R.string.localizable.home_menu_wallet_title(), subtitle: R.string.localizable.home_menu_wallet_subtitle())
        self.navigationItem.titleView = titleView
        
        let backButton = UIBarButtonItem(image: R.image.leftArrow(), style: .plain, target: self, action: #selector(backTapped))
        self.navigationItem.setLeftBarButton(backButton, animated: false)
    }

    // MARK: Actions
    
    @objc func backTapped() {
        router.goBack()
    }
    
    @objc func nextTapped() {
        let form = SetWalletPasswordForm(password: formFields.passwordField.textField.text, passwordBis: formFields.passwordBisField.textField.text)
        
        interactor.setPassword(request: SetWalletPasswordRequest(form: form))
    }
    
    // MARK: UI Update
    
    func handleUpdate(viewModel: SetWalletPasswordViewModel) {
        // TODO: Loading state
        // TODO: Error state
        
        log.info("State update: \(viewModel.state)")
        
        formFields.nextButton.isEnabled = viewModel.isNextButtonEnabled
        
        switch viewModel.state {
        case .completed(let wallet):
            self.view.endEditing(true)
            router.showWalletKeys(wallet: wallet)
        default:
            break
        }
    }
}