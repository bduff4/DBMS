/*
Brennan Duff
CSC 621
11/5/26
Assignment 5, extract parameters from URL query strings and use those values to execute a basic database query against a MySQL table, returning the results directly as JSON or plain text.
*/
const express = require('express');
const pool = require('./mysql');

const app = express();
const PORT = 3300;

// Escape HTML characters to prevent user data from being interpreted as HTML when displaying text results.
function escapeHtml(value) {
    return String(value ?? '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

// GET route at the root path
app.get('/', async (req, res) => {
    try {
        // Extract search parameters from the URL
        const { category, author } = req.query;

        // Extract the requested output format
        const format = typeof req.query.format === 'string'
            ? req.query.format.toLowerCase()
            : 'json';

        // Build the SQL query using available search parameters
        let conditions = [];
        let values = [];

        if (category) {
            conditions.push('category LIKE ?');
            values.push(`%${category}%`);
        }

        if (author) {
            conditions.push('author LIKE ?');
            values.push(`%${author}%`);
        }

        // Require at least one search parameter
        if (conditions.length === 0) {
            return res.status(400).json({
                error: 'Please provide an author or category search parameter.'
            });
        }

        const sql = `
            SELECT bookid, title, author, category, price
            FROM books
            WHERE ${conditions.join(' AND ')}
        `;

        // Execute the SQL query using the connection pool
        const [rows] = await pool.execute(sql, values);

        // Return results as readable HTML if text is requested
        if (format === 'text') {
            const tableRows = rows.map(book => `
                <tr>
                    <td>${escapeHtml(book.bookid)}</td>
                    <td>${escapeHtml(book.title)}</td>
                    <td>${escapeHtml(book.author)}</td>
                    <td>${escapeHtml(book.category)}</td>
                    <td>${escapeHtml(book.price)}</td>
                </tr>
            `).join('');

            const html = `
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Book Search Results</title>
                </head>
                <body>
                    <h1>Book Search Results</h1>
                    <table border="1" cellpadding="8">
                        <tr>
                            <th>Book ID</th>
                            <th>Title</th>
                            <th>Author</th>
                            <th>Category</th>
                            <th>Price</th>
                        </tr>
                        ${tableRows || '<tr><td colspan="5">No matching books found.</td></tr>'}
                    </table>
                </body>
                </html>
            `;

            return res.type('html').send(html);
        }

        // Return JSON by default
        res.json(rows);

    } catch (error) {
        console.error('Database Error:', error.message);

        res.status(500).json({
            error: 'An error occurred while retrieving books from the database.'
        });
    }
});

// Start the Express server
app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
