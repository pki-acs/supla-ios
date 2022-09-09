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


class ScenesVC: UIViewController {

    typealias Section = ScenesVM.Section

    @objc
    var scaleFactor = 1.0 {
        didSet {
            if oldValue != scaleFactor {
                _tableView.reloadData()
            }
        }
    }
    
    private let _tableView = UITableView()
    
    private let _sectionCellId = "section"
    private let _sceneCellId = "scene"

    private let _disposeBag = DisposeBag()
    
    private var _viewModel: ScenesVM!

    private var _sections = [Section]()
    
    private let _sectionToggle = PublishSubject<Int>()
    

    override func loadView() {
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view = _tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.separatorStyle = .none

        if #available(iOS 15.0, *) {
            _tableView.sectionHeaderTopPadding = 0
        }
        if #available(iOS 11.0, *) {
            _tableView.dragInteractionEnabled = false
        }
        _tableView.register(SceneCell.self,
                            forCellReuseIdentifier: _sceneCellId)
        _tableView.register(UINib(nibName: "SectionCell", bundle: nil),
                            forCellReuseIdentifier: _sectionCellId)
    }

    @objc
    func bind(viewModel: ScenesVM) {
        _viewModel = viewModel

        _viewModel.sections.subscribe { [weak self] ev in
            guard let self = self, let secs = ev.element else { return }

            self._sections = secs
            self._tableView.reloadData()
        }.disposed(by: _disposeBag)
        
        let inputs = ScenesVM.Inputs(sectionVisibilityToggle: _sectionToggle.asObservable())
        _viewModel.bind(inputs: inputs)
    }
}

extension ScenesVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return _sections.count
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return _sections[section].scenes.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: _sceneCellId,
                                                 for: indexPath) as! SceneCell
        cell.scaleFactor = scaleFactor
        cell.sceneData = _sections[indexPath.section].scenes[indexPath.row]
        
        return cell
    }
    
    
}

extension ScenesVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection sec: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: _sectionCellId) as? SASectionCell else {
            return nil
        }

        cell.delegate = self
        cell.label.text = _sections[sec].location.caption
        cell.ivCollapsed.isHidden = !_viewModel.isSectionCollapsed(sec)
        cell.tag = sec

        return cell
    }
    
    func tableView(_ : UITableView, heightForHeaderInSection: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        let separatorTag = 0xC31183
        let separatorHeight = CGFloat(1)
        let separatorInset = CGFloat(8)
        
        guard cell.viewWithTag(separatorTag) == nil else { return }
        let separator = UIView(frame: .zero)
        cell.addSubview(separator)
        separator.backgroundColor = .systemGray
        separator.tag = separatorTag
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
        separator.leftAnchor.constraint(equalTo: cell.leftAnchor,
                                        constant: separatorInset).isActive = true
        separator.rightAnchor.constraint(equalTo: cell.rightAnchor,
                                         constant: -separatorInset).isActive = true
        separator.bottomAnchor.constraint(equalTo: cell.bottomAnchor,
                                          constant: -2.0 * separatorHeight).isActive = true
    }
}

extension ScenesVC: SASectionCellDelegate {

    func sectionCellTouch(_ section: SASectionCell) {
        _sectionToggle.on(.next(section.tag))
    }
}
