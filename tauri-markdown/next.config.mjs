/** @type {import('next').NextConfig} */


const nextConfig = {
  // Ensure Next.js uses SSG instead of SSR  
  output: process.env.NODE_ENV === 'production' ? 'export' : null,
  // output: 'export',
};

export default nextConfig;