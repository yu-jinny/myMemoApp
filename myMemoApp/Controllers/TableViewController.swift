// TableViewController.swift
import UIKit

class TableViewController: UITableViewController {
    var todos: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTodos()
    }

    // MARK: - Todo 데이터 생성 (Create)
    func createTodo(text: String) {
        todos.append(text)
        UserDefaults.standard.set(todos, forKey: "todos")
        tableView.reloadData()
    }

    // MARK: - Todo 데이터 읽기 (Read)
    func loadTodos() {
        if let savedTodos = UserDefaults.standard.array(forKey: "todos") as? [String] {
            todos = savedTodos
            tableView.reloadData()
        }
    }

    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = todos[indexPath.row]
        return cell
    }

    // MARK: - 버튼 눌렀을 때 호출되는 메서드

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
