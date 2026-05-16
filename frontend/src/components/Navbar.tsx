import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '@/stores/auth';
import { BiMenu, BiX, BiLogOut, BiUser } from 'react-icons/bi';

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false);
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  if (!user) return null;

  const roleLabel = {
    super_admin: 'Super Admin',
    admin: 'Admin',
    school_owner: 'School Owner',
    teacher: 'Teacher',
    student: 'Student',
    parent: 'Parent',
    staff: 'Staff',
    government: 'Government',
    community: 'Community',
  }[user.role] || user.role;

  return (
    <nav className="bg-blue-600 text-white shadow-lg">
      <div className="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
        <Link to="/" className="flex items-center gap-2 font-bold text-xl">
          <span className="text-2xl">🎓</span>
          AI School
        </Link>

        <button
          className="md:hidden"
          onClick={() => setIsOpen(!isOpen)}
        >
          {isOpen ? <BiX size={24} /> : <BiMenu size={24} />}
        </button>

        <div className={`
          absolute md:static top-14 left-0 right-0 md:flex items-center gap-6
          ${isOpen ? 'bg-blue-600 block' : 'hidden md:flex'}
          md:gap-6 px-4 md:px-0 py-2 md:py-0
        `}>
          <div className="md:flex-1"></div>

          <div className="flex flex-col md:flex-row items-start md:items-center gap-3 md:gap-4">
            <span className="text-sm px-2 py-1 bg-blue-700 rounded">
              {roleLabel}
            </span>
            <Link
              to="/profile"
              className="hover:bg-blue-700 px-3 py-2 rounded flex items-center gap-2 transition"
            >
              <BiUser /> {user.name}
            </Link>
            <button
              onClick={handleLogout}
              className="hover:bg-red-600 px-3 py-2 rounded flex items-center gap-2 transition w-full md:w-auto justify-start md:justify-center bg-red-600 md:bg-transparent"
            >
              <BiLogOut /> Logout
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
}
