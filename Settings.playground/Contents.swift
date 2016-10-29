//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

protocol SettingsOptions {
    var options : [String] { get }
    var defaultValue : String { get }
}

class EnumSettingsOptions<T:Hashable> : SettingsOptions where T : RawRepresentable, T.RawValue == String {
    
    private let defaultVal : T
    init(defaultValue:T) {
        self.defaultVal = defaultValue
    }
    
    var defaultValue: String {
        return defaultVal.rawValue
    }
    
    var options : [String] {
        return Array(iterateEnum(T.self)).map { $0.rawValue }
    }
}

func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafePointer(to: &i) {
            $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
        }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}

class SettingsTableCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    static var reuseIdentifier: String {
        return "SettingsTableCell"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        accessoryView = nil
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }
    
}

enum Setting {
    
    case Toggle(label:String, id:String, default:Bool)
    case Slider(label:String, id:String, min:Float, max:Float, default:Float)
    case Text(label:String, id:String, default:String?)
    case Select(label:String, id:String, options:SettingsOptions)
    indirect case Group(title:String, children:[Setting])
    
}

protocol SettingsDataSource {
    
    func bool(forKey:String) -> Bool
    func float(forKey:String) -> Float
    func integer(forKey:String) -> Int
    func string(forKey:String) -> String?
    func hasValue(forKey:String) -> Bool
}


extension UserDefaults : SettingsDataSource {
    func hasValue(forKey key: String) -> Bool {
        guard let _ = value(forKey: key) else {
            return false
        }
        return true
    }

}

extension Setting {
    
    fileprivate func bool(forKey key:String, dataSource:SettingsDataSource) -> Bool {
        switch self {
        case let .Toggle(_,_,defaultValue):
            return dataSource.hasValue(forKey: key) ? dataSource.bool(forKey: key) : defaultValue
        default:
            fatalError()
        }
    }
    fileprivate func float(forKey key:String, dataSource:SettingsDataSource) -> Float {
        switch self {
        case let .Slider(_,_,_,_,defaultValue):
            return dataSource.hasValue(forKey: key) ? dataSource.float(forKey: key) : defaultValue
        default:
            fatalError()
        }

    }
    fileprivate func integer(forKey key:String, dataSource:SettingsDataSource) -> Int {
        return 3
    }
    fileprivate func string(forKey key:String, dataSource:SettingsDataSource) -> String? {
        switch self {
        case let .Text(_,_,defaultValue):
            return dataSource.hasValue(forKey: key) ? dataSource.string(forKey: key) : defaultValue

        case let .Select(_, id, settingsOptions):
            if dataSource.hasValue(forKey: key) {
                let proposedValue = dataSource.string(forKey: key)!
                if settingsOptions.options.contains(proposedValue) {
                    return proposedValue
                } else {
                    return settingsOptions.defaultValue
                }
            } else {
                return settingsOptions.defaultValue
            }

        default:
            fatalError()
        }

    }
    
    func configure(cell:UITableViewCell, dataSource:SettingsDataSource) {
        switch self {
        case .Group:
            fatalError()
            
        case let .Toggle(label,key,_):
            cell.textLabel?.text = label
            cell.detailTextLabel?.text = nil
            let s = UISwitch()
            s.isOn = bool(forKey: key, dataSource: dataSource)
            cell.accessoryView = s
            
        case let .Text(label,key,_):
            cell.textLabel?.text = label
            cell.detailTextLabel?.text = string(forKey: key, dataSource: dataSource)
            
        case let .Select(label, key, _):
            cell.textLabel?.text = label
            cell.detailTextLabel?.text = string(forKey: key, dataSource: dataSource)
            cell.accessoryType = .disclosureIndicator
            
        case .Slider:
            fatalError()
            
        default:
            fatalError()
        }
    }
}

// Base Class

class SettingsBaseViewController: UIViewController {
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.tableView!.register(SettingsTableCell.self, forCellReuseIdentifier: SettingsTableCell.reuseIdentifier)
        self.view.addSubview(self.tableView)
    }

}

// Settings Options
protocol SettingsOptionsViewControllerDelegate : class {
}

class SettingsOptionsViewController: SettingsBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.dataSource = self
    }
    
}

extension SettingsOptionsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension SettingsOptionsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.reuseIdentifier, for: indexPath) as! SettingsTableCell
        cell.textLabel?.text = "Hello"
        cell.accessoryType = .checkmark
        return cell
    }
}

// Main Settings

protocol SettingsViewControllerDelegate : class {
    func settingsViewController(vc:SettingsViewController, didUpdateSetting id:String)
}

class SettingsViewController: SettingsBaseViewController {
    
    weak var delegate : SettingsViewControllerDelegate?
    
    private var items : [Setting] = []
    fileprivate var defaultsStore : UserDefaults
    
    init(settings:[Setting], delegate:SettingsViewControllerDelegate) {
        self.defaultsStore = UserDefaults.standard
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        
        items = settings
    }
    
    func setting(for section:Int) -> Setting {
        return items[section]
    }
    
    var numberOfGroups : Int {
        return items.count
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
    }
    
}

extension SettingsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let optionsVC = SettingsOptionsViewController()
        optionsVC.view.frame = view.frame
        optionsVC.tableView.frame = view.frame
        navigationController?.pushViewController(optionsVC, animated: true)
    }
}

extension SettingsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfGroups
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item = setting(for: section)
        switch item {
        case let .Group(name, _):
            return name
        case let .Select(label: label, _, _):
            return label
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = setting(for: section)
        switch item {
        case let .Group(_, groupSettings):
            return groupSettings.count
        case let .Select(label: label, id: id, options: options):
            return options.options.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.reuseIdentifier, for: indexPath) as! SettingsTableCell
        
        let item = setting(for: indexPath.section)
        
        switch item {
        case let .Group(_, groupSettings):
            groupSettings[indexPath.row].configure(cell: cell, dataSource:self.defaultsStore)
        case let .Select(label, key, options):
            let options = options.options
            let valueToDisplay = options[indexPath.row]
            cell.textLabel?.text = valueToDisplay
            let currentValue = item.string(forKey: key, dataSource: self.defaultsStore)
            cell.accessoryType = (valueToDisplay == currentValue) ? .checkmark : .none
        default:
            break
        }
        
        return cell
        
    }

}

enum Test : String {
    case Lady
    case Tramp
}

enum Speed : String {
    case Fast
    case Faster
    case Fastest
}

let speedOptions = EnumSettingsOptions<Speed>(defaultValue:.Fastest)
let whoOptions = EnumSettingsOptions<Test>(defaultValue:.Lady)


let settings = [
    Setting.Group(title:"General", children:[
        Setting.Toggle(label:"Foo", id:"general.foo", default:true),
        Setting.Toggle(label:"Bar", id:"general.bar", default:false),
        Setting.Select(label:"Bar2", id:"general.bar2", options:whoOptions),
        Setting.Text(label:"Baz", id:"general.baz", default:"Saskatoon"),
    ]),
    Setting.Select(label:"How fast?", id:"speed", options:speedOptions),
    Setting.Group(title:"Extra", children:[
        Setting.Toggle(label:"Foo", id:"extra.foo", default:false),
        Setting.Toggle(label:"Bar", id:"extra.bar", default:true),
        Setting.Text(label:"Baz", id:"extra.baz", default:"Tom"),
    ])
]

class TheDelegate : SettingsViewControllerDelegate {
    func settingsViewController(vc: SettingsViewController, didUpdateSetting id: String) {
        print("Update: \(id)")
    }
}

var theDelegate = TheDelegate()

var defaults = UserDefaults.standard
defaults.set("Whhooppeee", forKey: "general.baz")
defaults.synchronize()

var ctrl = SettingsViewController(settings:settings, delegate:theDelegate)
let nav = UINavigationController(rootViewController: ctrl)
nav.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
ctrl.title = "Settings Example"
ctrl.view.frame = nav.view.frame
ctrl.tableView.frame = ctrl.view.frame
PlaygroundPage.current.liveView = nav.view

