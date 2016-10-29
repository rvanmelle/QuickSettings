//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

protocol SettingsOptions {
    var options : [String] { get }
    var defaultValue : String { get }
}

class EnumSettingsOptions<T> : SettingsOptions where T : RawRepresentable, T.RawValue == String {
    
    private let defaultVal : T
    init(defaultValue:T) {
        self.defaultVal = defaultValue
    }
    
    var defaultValue: String {
        return defaultVal.rawValue
    }
    
    var options : [String] {
        return Array(iterateEnum(Test.self)).map { $0.rawValue }
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
    
}

/*extension RawRepresentable : SettingsOptions where RawValue == String {
    
}*/

//protocol SettingOptionType : RawRepresentable where RawRepresentable.RawValue == String {
    //associatedtype SettingIdentifier: RawRepresentable
//}

enum Setting {
    
    case Toggle(label:String, id:String, default:Bool)
    case Slider(label:String, id:String, min:Float, max:Float, default:Float)
    case Text(label:String, id:String, default:String?)
    case Select(label:String, id:String, options:SettingsOptions)
    indirect case Group(title:String, children:[Setting])
    
}

extension Setting {
    func configure(cell:UITableViewCell) {
        switch self {
        case .Group:
            fatalError()
            
        case let .Toggle(label,_,defaultValue):
            cell.textLabel?.text = label
            let s = UISwitch()
            s.isOn = defaultValue
            cell.accessoryView = s
            
        case let .Text(label,_,defaultValue):
            cell.textLabel?.text = label
            cell.detailTextLabel?.text = defaultValue
            
        case let .Select(label: label, id: _, options: options):
            cell.textLabel?.text = label
            cell.detailTextLabel?.text = options.defaultValue
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
    private var defaultsStore : UserDefaults
    
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
    }
    
}

extension SettingsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.reuseIdentifier, for: indexPath) as! SettingsTableCell
        let item = setting(for: indexPath.section)
        
        switch item {
        case let .Group(_, groupSettings):
            groupSettings[indexPath.row].configure(cell: cell)
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

let o = EnumSettingsOptions<Test>(defaultValue:.Lady)

let settings = [
    Setting.Group(title:"General", children:[
        Setting.Toggle(label:"Foo", id:"general.foo", default:true),
        Setting.Toggle(label:"Bar", id:"general.bar", default:false),
        Setting.Select(label:"Bar2", id:"general.bar2", options:o),
        Setting.Text(label:"Baz", id:"general.baz", default:"Saskatoon"),
    ]),
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
var ctrl = SettingsViewController(settings:settings, delegate:theDelegate)
ctrl.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
ctrl.tableView.frame = ctrl.view.frame
PlaygroundPage.current.liveView = ctrl.view

