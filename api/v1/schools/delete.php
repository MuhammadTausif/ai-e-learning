<?php
requireRole(['super_admin', 'admin']);
$id = (int)($_GET['id'] ?? 0);

Database::query('UPDATE schools SET status=$1 WHERE id=$2', ['inactive', $id]);
sendJson(['message' => 'School deleted']);
