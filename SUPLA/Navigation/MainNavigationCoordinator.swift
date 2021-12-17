/*
 Copyright (C) AC SOFTWARE SP. Z O.O.
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */


import UIKit
import RxSwift
import RxCocoa

@objc
class MainNavigationCoordinator: BaseNavigationCoordinator {
    override var viewController: UIViewController {
        return navigationController
    }
    
    private let disposeBag = DisposeBag()
    
    private let navigationController: UINavigationController
    
    private var mainVC: SAMainVC

    
    private var pendingFlow: NavigationCoordinator?
    
    override init() {
        mainVC = SAMainVC(nibName: "MainVC", bundle: nil)
        navigationController = SuplaNavigationController(rootViewController: mainVC)
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onRegistered(_:)),
                                               name: .saRegistered,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    private func showInitialView() {
        if SAApp.configIsSet() {
            showStatusView(progress: 0)
        } else {
            showAuthView(immediate: true)
        }
    }
    
    private func updateNavBar() {
        let showNav = SAApp.configIsSet() && SAApp.isClientRegistered()
        navigationController.setNavigationBarHidden(!showNav,
                                                    animated: true)
    }

    override func start(from parent: NavigationCoordinator?) {
        showInitialView()
    }
    
    override func startFlow(coordinator child: NavigationCoordinator) {
        if currentCoordinator is PresentationNavigationCoordinator {
            // Finish presenting before going to other screen
            pendingFlow = child
            currentCoordinator.finish()
        } else {
            if child is PresentationNavigationCoordinator {
                navigationController.present(child.viewController,
                                             animated: child.wantsAnimatedTransitions)
            } else {
                updateNavBar()
                navigationController.pushViewController(child.viewController,
                                                        animated: child.wantsAnimatedTransitions)
            }
            super.startFlow(coordinator: child)
        }
    }
    
    override func didFinish(coordinator child: NavigationCoordinator) {
        if child is PresentationNavigationCoordinator {
            navigationController.dismiss(animated: child.wantsAnimatedTransitions) {
                super.didFinish(coordinator: child)
                self.resumeFlowIfNeeded()
            }
        } else {
            updateNavBar()
            navigationController.popViewController(animated: child.wantsAnimatedTransitions)
            super.didFinish(coordinator: child)
            self.resumeFlowIfNeeded()
        }
    }
    
    private func resumeFlowIfNeeded() {
        if let resumeFlow = pendingFlow {
            pendingFlow = nil
            startFlow(coordinator: resumeFlow)
        }
    }

    
    func showSettingsView() {
        startFlow(coordinator: CfgNavigationCoordinator())
    }
    
    func showAddWizard() {
        let avc = SAAddWizardVC(nibName: "AddWizardVC", bundle: nil)
        avc.modalPresentationStyle = .fullScreen
        avc.modalTransitionStyle = .crossDissolve
        startFlow(coordinator: PresentationNavigationCoordinator(viewController: avc))
    }
    
   
    func showAbout() {
        pushLegacyViewController(named: "AboutVC", of: SAAboutVC.self)
    }
    
    private func pushLegacyViewController<T>(named: String, of: T.Type)
        where T: BaseViewController {
            if currentCoordinator !== self {
                currentCoordinator.finish()
            }
        let vc = T(nibName: named, bundle: nil)
        vc.navigationCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    @objc
    func attach(to window: UIWindow) {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    // MARK: -
    // MARK: Public interface
    // MARK: -
    
    @objc func showAuthView(immediate: Bool) {
        startFlow(coordinator: AuthCfgNavigationCoordinator(immediate: immediate))
    }
    
    @objc func showStatusView(progress: NSNumber) {
        activeStatusController().setStatusConnectingProgress(progress.floatValue)
    }

    @objc func showStatusView(error: String) {
        activeStatusController().setStatusError(error)
    }
    
    private func activeStatusController() -> SAStatusVC {
        let vc: SAStatusVC
        if let visiblePresentation = currentCoordinator as? PresentationNavigationCoordinator,
           let statusController = visiblePresentation.viewController as? SAStatusVC {
            // already displaying status view
            vc = statusController
        } else {
            // no status display yet, so let's create new controller
            vc = SAStatusVC(nibName: "StatusVC", bundle: nil)
            let pc = PresentationNavigationCoordinator(viewController: vc)
            startFlow(coordinator: pc)
        }
        return vc
    }
    

    @objc func toggleMenuBar() {
        let show: Bool
        if currentCoordinator is PresentationNavigationCoordinator {
            show = currentCoordinator.viewController is SuplaMenuController
            currentCoordinator.finish()
        } else {
            show = true
        }
        if show {
            startFlow(coordinator: PresentationNavigationCoordinator(viewController: SuplaMenuController()))
        }
    }
    
    
    // MARK: -
    // MARK: Application life cycle support
    // MARK: -
    @objc
    private func onRegistered(_ notification: Notification) {
        if currentCoordinator is PresentationNavigationCoordinator &&
           currentCoordinator.viewController is SAStatusVC {
            DispatchQueue.main.async {
                self.currentCoordinator.finish()
            }
        }
        self.updateNavBar()

    }
}

