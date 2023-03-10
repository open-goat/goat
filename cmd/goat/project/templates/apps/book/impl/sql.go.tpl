package impl

const (
	insertBook = `INSERT INTO books(id,status,create_at,create_by,book_name,author) VALUES (?,?,?,?,?,?);`

	queryBook = `SELECT * FROM books Where status > 0 AND book_name Like ? AND author Like ? LIMIT ?,?`

	describeBook = `SELECT * FROM books Where status > 0 AND id = ?`

	updateBook = `UPDATE books SET update_at=?,update_by=?,book_name=?,author=? WHERE id =?`

	deleteBook = `UPDATE books SET status=0 WHERE id = ?`
)
