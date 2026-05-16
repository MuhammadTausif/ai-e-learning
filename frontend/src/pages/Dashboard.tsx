import { useEffect, useState } from 'react';
import { useAuth } from '@/stores/auth';
import { apiClient } from '@/services/api';
import { BiLoaderAlt } from 'react-icons/bi';

export function Dashboard() {
  const { user } = useAuth();
  const [data, setData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchDashboard = async () => {
      try {
        const response = await apiClient.get('/dashboard');
        setData(response);
      } catch (error) {
        console.error('Failed to fetch dashboard', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchDashboard();
  }, []);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <BiLoaderAlt className="animate-spin text-4xl text-blue-600" />
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto p-4">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-800">Welcome, {user?.name}! 👋</h1>
        <p className="text-gray-600 mt-2">{new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' })}</p>
      </div>

      {/* Stats */}
      {data?.stats && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          {Object.entries(data.stats).map(([key, value]: [string, any]) => (
            <div key={key} className="bg-white rounded-lg shadow p-6">
              <div className="text-2xl font-bold text-blue-600">{value}</div>
              <div className="text-gray-600 text-sm mt-1 capitalize">
                {key.replace(/([A-Z])/g, ' $1').trim()}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Role-specific content */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-bold text-gray-800 mb-4">Dashboard for {user?.role}</h2>
        <pre className="bg-gray-50 p-4 rounded text-xs overflow-auto">
          {JSON.stringify(data, null, 2)}
        </pre>
      </div>
    </div>
  );
}
