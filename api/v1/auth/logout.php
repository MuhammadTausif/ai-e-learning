<?php
requireAuth();
sendJson(['message' => 'Logged out successfully'], 200);
