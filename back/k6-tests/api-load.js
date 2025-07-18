import http from 'k6/http';
import { check } from 'k6';

export default function () {
  const res = http.get('https://ton-backend-render.io/api/health');
  check(res, { 'status is 200': (r) => r.status === 200 });
}
