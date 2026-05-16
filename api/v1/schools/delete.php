<?php
requireRole(['super_admin', 'admin']);
$id = (int)($_GET['id'] ?? 0);
Database::query('UPDATE schools SET status=? WHERE id=?', ['inactive', $id]);
sendJson(['message' => 'School deleted']);
