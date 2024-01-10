// TableViewController.swift

import UIKit

struct TodoItem {
    var text: String
    var isCompleted: Bool

    // TodoItem을 Dictionary로 변환하는 속성
    var dictionary: [String: Any] {
        return ["text": text, "isCompleted": isCompleted]
    }
}

class TableViewController: UITableViewController {
    var todos: [TodoItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTodos()
    }

    // MARK: - Todo 데이터 생성 (Create)
    func createTodo(text: String) {
        let newTodo = TodoItem(text: text, isCompleted: false)
        todos.append(newTodo)
        UserDefaults.standard.set(todos.map { $0.dictionary }, forKey: "todos")
        tableView.reloadData()
    }

    // MARK: - Todo 데이터 읽기 (Read)
    func loadTodos() {
        if let savedTodos = UserDefaults.standard.array(forKey: "todos") as? [[String: Any]] {
            todos = savedTodos.compactMap { dictionary in
                guard let text = dictionary["text"] as? String, let isCompleted = dictionary["isCompleted"] as? Bool else {
                    return nil
                }
                return TodoItem(text: text, isCompleted: isCompleted)
            }
            tableView.reloadData()
        }
    }

    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // TodoItem에서 스위치 상태 및 텍스트를 가져와 설정
        let todoItem = todos[indexPath.row]
        cell.textLabel?.text = todoItem.text

        let switchView = UISwitch()
        switchView.isOn = todoItem.isCompleted
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)

        // 태그를 이용해 행 번호 저장
        switchView.tag = indexPath.row

        // AccessoryView로 스위치 추가
        cell.accessoryView = switchView

        // 스위치 상태에 따라 텍스트 가운데 줄 추가
        updateTextStrikeThrough(cell: cell, isCompleted: todoItem.isCompleted)

        return cell
    }

    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 1. 삭제 버튼이 눌린 행의 데이터를 배열에서 제거
            todos.remove(at: indexPath.row)

            // 2. 변경된 데이터를 UserDefaults에 저장
            UserDefaults.standard.set(todos.map { $0.dictionary }, forKey: "todos")

            // 3. TableView에서 해당 행을 삭제
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // 추가 버튼을 눌렀을 때 필요한 경우
        }
    }

    // MARK: - 스위치 상태가 변경될 때 호출되는 메서드
    @objc func switchChanged(_ sender: UISwitch) {
        let row = sender.tag

        // TodoItem에서 스위치 상태 변경 및 저장
        todos[row].isCompleted = sender.isOn
        UserDefaults.standard.set(todos.map { $0.dictionary }, forKey: "todos")

        // 텍스트의 가운데 줄 상태 업데이트
        if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) {
            updateTextStrikeThrough(cell: cell, isCompleted: sender.isOn)
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

        // 3. UIAlertAction을 추가하고, 텍스트 필드에서 입력받은 값을 이용하여 Todo를 생성합니다.
        let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first, let todoText = textField.text {
                self?.createTodo(text: todoText)
            }
        }

        // 4. 팝업에 액션 추가 및 보여주기
        alertController.addAction(addAction)
        present(alertController, animated: true, completion: nil)
    }
}
