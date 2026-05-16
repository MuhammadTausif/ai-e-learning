<?php
requireRole(['super_admin', 'admin']);
$id     = (int)($_GET['id'] ?? 0);
$school = Database::fetchOne('SELECT * FROM schools WHERE id = ?', [$id]);
if (!$school) sendError('School not found', 404);
sendJson(['data' => $school]);
