<?php
$user      = requireAuth();
$role      = $user['role'];
$user_id   = (int)$user['id'];
$school_id = (int)($user['school_id'] ?? 0);

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
            'teachers' => Database::fetchOne("SELECT COUNT(*) AS c FROM users WHERE school_id=? AND role='teacher' AND status='active'", [$school_id])['c'] ?? 0,
            'students' => Database::fetchOne("SELECT COUNT(*) AS c FROM users WHERE school_id=? AND role='student' AND status='active'", [$school_id])['c'] ?? 0,
            'classes'  => Database::fetchOne("SELECT COUNT(*) AS c FROM classes WHERE school_id=? AND status='active'", [$school_id])['c'] ?? 0,
            'staff'    => Database::fetchOne("SELECT COUNT(*) AS c FROM users WHERE school_id=? AND role='staff' AND status='active'", [$school_id])['c'] ?? 0,
        ];
        $dashboard['school'] = Database::fetchOne('SELECT id, name, city, state FROM schools WHERE id=?', [$school_id]);
        break;

    case 'teacher':
        $dashboard['stats'] = [
            'classes'        => count(Database::fetchAll("SELECT id FROM classes WHERE class_teacher_id=? AND status='active'", [$user_id])),
            'subjects'       => count(Database::fetchAll("SELECT id FROM subjects WHERE teacher_id=? AND status='active'", [$user_id])),
            'pendingGrading' => Database::fetchOne(
                "SELECT COUNT(*) AS c FROM assignment_submissions asub
                 JOIN assignments a ON a.id = asub.assignment_id
                 JOIN subjects s ON s.id = a.subject_id
                 WHERE s.teacher_id=? AND asub.graded_at IS NULL",
                [$user_id]
            )['c'] ?? 0,
        ];
        break;

    case 'student':
        $profile  = Database::fetchOne('SELECT class_id FROM student_profiles WHERE user_id=?', [$user_id]);
        $class_id = (int)($profile['class_id'] ?? 0);

        $att = Database::fetchOne(
            "SELECT
               SUM(status='present') AS present,
               COUNT(*) AS total
             FROM attendance
             WHERE student_id=? AND MONTH(date)=MONTH(CURDATE()) AND YEAR(date)=YEAR(CURDATE())",
            [$user_id]
        );
        $pct = ($att['total'] ?? 0) > 0
            ? round(($att['present'] ?? 0) / $att['total'] * 100)
            : 0;

        $dashboard['stats'] = [
            'attendancePct'      => $pct,
            'avgGrade'           => Database::fetchOne(
                "SELECT ROUND(AVG(marks_obtained/NULLIF(max_marks,0)*100),1) AS avg FROM grades WHERE student_id=?",
                [$user_id]
            )['avg'] ?? null,
            'pendingAssignments' => Database::fetchOne(
                "SELECT COUNT(*) AS c FROM assignments a
                 LEFT JOIN assignment_submissions asub ON asub.assignment_id=a.id AND asub.student_id=?
                 WHERE a.class_id=? AND asub.id IS NULL AND a.due_date > NOW()",
                [$user_id, $class_id]
            )['c'] ?? 0,
        ];
        break;

    case 'parent':
        $children = Database::fetchAll(
            "SELECT u.id, u.first_name, u.last_name, c.name AS class_name
             FROM parent_student ps
             JOIN users u ON u.id = ps.student_id
             LEFT JOIN student_profiles sp ON sp.user_id = u.id
             LEFT JOIN classes c ON c.id = sp.class_id
             WHERE ps.parent_id=? AND u.status='active'",
            [$user_id]
        );
        $dashboard['children'] = $children;
        if (!empty($children)) {
            $child_id = (int)$children[0]['id'];
            $att = Database::fetchOne(
                "SELECT SUM(status='present') AS present, COUNT(*) AS total FROM attendance
                 WHERE student_id=? AND MONTH(date)=MONTH(CURDATE()) AND YEAR(date)=YEAR(CURDATE())",
                [$child_id]
            );
            $dashboard['stats'] = [
                'childAttendancePct' => ($att['total'] ?? 0) > 0
                    ? round(($att['present'] ?? 0) / $att['total'] * 100)
                    : 0,
                'childAvgGrade' => Database::fetchOne(
                    "SELECT ROUND(AVG(marks_obtained/NULLIF(max_marks,0)*100),1) AS avg FROM grades WHERE student_id=?",
                    [$child_id]
                )['avg'] ?? null,
            ];
        }
        break;

    default:
        $dashboard['stats'] = [];
}

sendJson($dashboard, 200);
