<?php
$user = requireAuth();
$role = $user['role'];
$user_id = $user['id'];
$school_id = $user['school_id'] ?? null;

$dashboard = ['role' => $role];

switch ($role) {
    case 'super_admin':
    case 'admin':
        $dashboard['stats'] = [
            'schools'  => Database::fetchOne("SELECT COUNT(*) AS c FROM schools WHERE status='active'")['c'],
            'users'    => Database::fetchOne("SELECT COUNT(*) AS c FROM users WHERE status='active'")['c'],
            'students' => Database::fetchOne("SELECT COUNT(*) AS c FROM users WHERE role='student' AND status='active'")['c'],
            'teachers' => Database::fetchOne("SELECT COUNT(*) AS c FROM users WHERE role='teacher' AND status='active'")['c'],
        ];
        $dashboard['recentSchools'] = Database::fetchAll(
            "SELECT id, name, city, status, created_at FROM schools ORDER BY created_at DESC LIMIT 5"
        );
        break;

    case 'school_owner':
        $dashboard['stats'] = [
            'teachers' => Database::fetchOne("SELECT COUNT(*) AS c FROM users WHERE school_id=$1 AND role='teacher' AND status='active'", [$school_id])['c'] ?? 0,
            'students' => Database::fetchOne("SELECT COUNT(*) AS c FROM users WHERE school_id=$1 AND role='student' AND status='active'", [$school_id])['c'] ?? 0,
            'classes'  => Database::fetchOne("SELECT COUNT(*) AS c FROM classes WHERE school_id=$1 AND status='active'", [$school_id])['c'] ?? 0,
            'staff'    => Database::fetchOne("SELECT COUNT(*) AS c FROM users WHERE school_id=$1 AND role='staff' AND status='active'", [$school_id])['c'] ?? 0,
        ];
        $dashboard['school'] = Database::fetchOne('SELECT id, name, city, state FROM schools WHERE id=$1', [$school_id]);
        break;

    case 'teacher':
        $dashboard['stats'] = [
            'classes'          => count(Database::fetchAll("SELECT id FROM classes WHERE class_teacher_id=$1 AND status='active'", [$user_id])),
            'subjects'         => count(Database::fetchAll("SELECT id FROM subjects WHERE teacher_id=$1 AND status='active'", [$user_id])),
            'pendingGrading'   => Database::fetchOne("SELECT COUNT(*) AS c FROM assignment_submissions asub JOIN assignments a ON a.id = asub.assignment_id JOIN subjects s ON s.id = a.subject_id WHERE s.teacher_id=$1 AND asub.graded_at IS NULL", [$user_id])['c'] ?? 0,
        ];
        break;

    case 'student':
        $profile = Database::fetchOne('SELECT class_id FROM student_profiles WHERE user_id=$1', [$user_id]);
        $class_id = $profile['class_id'] ?? null;

        $att = Database::fetchOne(
            "SELECT COUNT(*) FILTER (WHERE status='present') AS present, COUNT(*) AS total FROM attendance WHERE student_id=$1 AND date >= date_trunc('month', CURRENT_DATE)",
            [$user_id]
        );
        $pct = ($att['total'] ?? 0) > 0 ? round(($att['present'] ?? 0) / $att['total'] * 100) : 0;

        $dashboard['stats'] = [
            'attendance'  => $pct,
            'avgGrade'    => Database::fetchOne("SELECT ROUND(AVG(marks_obtained/NULLIF(max_marks,0)*100),1) AS avg FROM grades WHERE student_id=$1", [$user_id])['avg'] ?? null,
            'pendingAssignments' => Database::fetchOne(
                "SELECT COUNT(*) AS c FROM assignments a LEFT JOIN assignment_submissions asub ON asub.assignment_id=a.id AND asub.student_id=$1 WHERE a.class_id=$2 AND asub.id IS NULL AND a.due_date > NOW()",
                [$user_id, $class_id]
            )['c'] ?? 0,
        ];
        break;

    case 'parent':
        $children = Database::fetchAll(
            "SELECT u.id, u.first_name, u.last_name, c.name AS class_name FROM parent_student ps JOIN users u ON u.id = ps.student_id LEFT JOIN student_profiles sp ON sp.user_id = u.id LEFT JOIN classes c ON c.id = sp.class_id WHERE ps.parent_id=$1 AND u.status='active'",
            [$user_id]
        );
        $dashboard['children'] = $children;
        if (count($children) > 0) {
            $child_id = (int)$children[0]['id'];
            $dashboard['stats'] = [
                'attendance' => Database::fetchOne("SELECT COUNT(*) FILTER (WHERE status='present') AS present, COUNT(*) AS total FROM attendance WHERE student_id=$1 AND date >= date_trunc('month', CURRENT_DATE)", [$child_id]),
                'avgGrade'   => Database::fetchOne("SELECT ROUND(AVG(marks_obtained/NULLIF(max_marks,0)*100),1) AS avg FROM grades WHERE student_id=$1", [$child_id])['avg'] ?? null,
            ];
        }
        break;

    default:
        $dashboard['stats'] = [];
}

sendJson($dashboard, 200);
