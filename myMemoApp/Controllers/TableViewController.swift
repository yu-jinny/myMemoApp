// TableViewController.swift
import UIKit

struct TodoItem {
    var text: String
    var isCompleted: Bool
    var category: String // TodoItem에 카테고리 추가

    // TodoItem을 Dictionary로 변환하는 속성
    var dictionary: [String: Any] {
        return ["text": text, "isCompleted": isCompleted, "category": category]
    }
}

class TableViewController: UITableViewController {
    var todos: [TodoItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTodos()
    }

    // MARK: - Todo 데이터 생성 (Create)
    func createTodo(text: String, category: String) {
        let newTodo = TodoItem(text: text, isCompleted: false, category: category)
        todos.append(newTodo)
        UserDefaults.standard.set(todos.map { $0.dictionary }, forKey: "todos")
        tableView.reloadData()
    }

    // MARK: - Todo 데이터 읽기 (Read)
    func loadTodos() {
        if let savedTodos = UserDefaults.standard.array(forKey: "todos") as? [[String: Any]] {
            todos = savedTodos.compactMap { dictionary in
                guard let text = dictionary["text"] as? String,
                      let isCompleted = dictionary["isCompleted"] as? Bool,
                      let category = dictionary["category"] as? String else {
                    return nil
                }
                return TodoItem(text: text, isCompleted: isCompleted, category: category)
            }
            tableView.reloadData()
        }
    }

    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        // 카테고리별로 섹션 나누기
        let categories = Set(todos.map { $0.category })
        return categories.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 각 섹션별로 해당 카테고리에 속하는 Todo 개수 반환
        let category = Array(Set(todos.map { $0.category }))[section]
        return todos.filter { $0.category == category }.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 각 섹션의 카테고리명 반환
        return Array(Set(todos.map { $0.category }))[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // 각 섹션과 행에 해당하는 TodoItem 가져오기
        let category = Array(Set(todos.map { $0.category }))[indexPath.section]
        let todosInSection = todos.filter { $0.category == category }
        let todoItem = todosInSection[indexPath.row]

        // TodoItem에서 스위치 상태 및 텍스트를 가져와 설정
        cell.textLabel?.text = todoItem.text

        let switchView = UISwitch()
        switchView.isOn = todoItem.isCompleted
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        switchView.tag = indexPath.row // 태그를 이용해 행 번호 저장

        // AccessoryView로 스위치 추가
        cell.accessoryView = switchView

        // 스위치 상태에 따라 텍스트 가운데 줄 추가
        updateTextStrikeThrough(cell: cell, isCompleted: todoItem.isCompleted)

        return cell
    }

    // MARK: - 스위치 상태가 변경될 때 호출되는 메서드
    @objc func switchChanged(_ sender: UISwitch) {
        let indexPath = indexPathForSwitch(sender)
        if let indexPath = indexPath {
            // TodoItem에서 스위치 상태 변경 및 저장
            todos[indexPath.row].isCompleted = sender.isOn
            UserDefaults.standard.set(todos.map { $0.dictionary }, forKey: "todos")

            // 텍스트의 가운데 줄 상태 업데이트
            if let cell = tableView.cellForRow(at: indexPath) {
                updateTextStrikeThrough(cell: cell, isCompleted: sender.isOn)
            }
        }
    }

    // MARK: - 텍스트 가운데 줄 상태 업데이트
    func updateTextStrikeThrough(cell: UITableViewCell, isCompleted: Bool) {
        if isCompleted {
            // 텍스트에 가운데 줄 추가
            let attributeString = NSAttributedString(string: cell.textLabel?.text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            cell.textLabel?.attributedText = attributeString
        } else {
            // 가운데 줄 제거
            let attributeString = NSAttributedString(string: cell.textLabel?.text ?? "")
            cell.textLabel?.attributedText = attributeString
        }
    }

    // MARK: - 스위치의 indexPath를 찾아주는 도우미 메서드
    func indexPathForSwitch(_ sender: UISwitch) -> IndexPath? {
        let point = sender.convert(CGPoint.zero, to: tableView)
        return tableView.indexPathForRow(at: point)
    }

    // MARK: - 수정 기능 추가
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1. UIAlertController를 이용해 입력을 받을 수 있는 팝업을 띄웁니다.
        let alertController = UIAlertController(title: "Todo 수정", message: "새로운 내용을 입력하세요", preferredStyle: .alert)

        // 2. UIAlertController에 텍스트 필드 추가하고 기존 TodoItem의 텍스트로 초기화
        alertController.addTextField { textField in
            textField.text = self.todos[indexPath.row].text
        }

        // 3. UIAlertAction을 추가하고, 텍스트 필드에서 입력받은 값을 이용하여 Todo를 수정합니다.
        let editAction = UIAlertAction(title: "수정", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first, let todoText = textField.text {
                self?.todos[indexPath.row].text = todoText
                UserDefaults.standard.set(self?.todos.map { $0.dictionary }, forKey: "todos")
                tableView.reloadData()
            }
        }

        // 4. 팝업에 액션 추가 및 보여주기
        alertController.addAction(editAction)
        present(alertController, animated: true, completion: nil)

        // 선택한 행의 강조 효과 제거
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - 스와이프로 수정 및 삭제 가능하도록 설정
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "수정") { [weak self] _, indexPath in
            self?.editTodoItem(at: indexPath)
        }
        editAction.backgroundColor = .systemTeal

        let deleteAction = UITableViewRowAction(style: .destructive, title: "삭제") { [weak self] _, indexPath in
            self?.deleteTodoItem(at: indexPath)
        }

        return [deleteAction, editAction]
    }

    // MARK: - 수정 액션 실행 메서드
    func editTodoItem(at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView(self.tableView, didSelectRowAt: indexPath)
    }

    // MARK: - 삭제 액션 실행 메서드
    func deleteTodoItem(at indexPath: IndexPath) {
        tableView(self.tableView, commit: .delete, forRowAt: indexPath)
    }
    @IBAction func addTodoButtonTapped(_ sender: UIBarButtonItem) {
        print("버튼 클릭 : 추가")
        // 1. UIAlertController를 이용해 입력을 받을 수 있는 팝업을 띄웁니다.
                let alertController = UIAlertController(title: "새로운 Todo", message: "할 일을 입력하세요", preferredStyle: .alert)

                // 2. UIAlertController에 텍스트 필드 추가
                alertController.addTextField { textField in
                    textField.placeholder = "할 일을 입력하세요"
                }

                // 3. 추가로 텍스트 필드 추가하여 카테고리 입력 받기
                alertController.addTextField { categoryTextField in
                    categoryTextField.placeholder = "카테고리를 입력하세요"
                }

                // 4. UIAlertAction을 추가하고, 텍스트 필드에서 입력받은 값을 이용하여 Todo를 생성합니다.
                let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
                    if let textField = alertController.textFields?.first,
                       let categoryTextField = alertController.textFields?[1],
                       let todoText = textField.text,
                       let category = categoryTextField.text {
                        self?.createTodo(text: todoText, category: category)
                    }
                }

                // 5. 팝업에 액션 추가 및 보여주기
                alertController.addAction(addAction)
                present(alertController, animated: true, completion: nil)
            }
        }
