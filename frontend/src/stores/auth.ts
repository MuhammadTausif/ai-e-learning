import { create } from 'zustand';
import { User } from '@/types';
import { apiClient } from '@/services/api';

interface AuthState {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  token: string | null;

  // Actions
  login: (email: string, password: string) => Promise<void>;
  register: (first_name: string, last_name: string, email: string, password: string, role: string) => Promise<void>;
  logout: () => void;
  fetchUser: () => Promise<void>;
  setUser: (user: User | null) => void;
  clearError: () => void;
}

export const useAuth = create<AuthState>((set) => ({
  user: null,
  isLoading: false,
  error: null,
  token: localStorage.getItem('token'),

  login: async (email, password) => {
    set({ isLoading: true, error: null });
    try {
      const response: any = await apiClient.post('/auth/login', { email, password });
      apiClient.setToken(response.token);
      set({ user: response.user, token: response.token, isLoading: false });
    } catch (error: any) {
      const message = error.response?.data?.error || 'Login failed';
      set({ error: message, isLoading: false });
      throw error;
    }
  },

  register: async (first_name, last_name, email, password, role) => {
    set({ isLoading: true, error: null });
    try {
      await apiClient.post('/auth/register', { first_name, last_name, email, password, role });
      set({ isLoading: false });
    } catch (error: any) {
      const message = error.response?.data?.error || 'Registration failed';
      set({ error: message, isLoading: false });
      throw error;
    }
  },

  logout: () => {
    apiClient.clearToken();
    set({ user: null, token: null });
  },

  fetchUser: async () => {
    set({ isLoading: true });
    try {
      const response: any = await apiClient.get('/auth/me');
      set({ user: response.user, isLoading: false });
    } catch (error) {
      set({ user: null, token: null, isLoading: false });
    }
  },

  setUser: (user) => set({ user }),
  clearError: () => set({ error: null }),
}));
