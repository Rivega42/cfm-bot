import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  // React strict mode for better development experience
  reactStrictMode: true,
  
  // Use SWC minifier for better performance
  swcMinify: true,
  
  // Image optimization
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'api.telegram.org',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: 't.me',
        pathname: '/**',
      },
    ],
  },
  
  // Experimental features
  experimental: {
    // Enable server actions
    serverActions: {
      bodySizeLimit: '2mb',
    },
    // Optimize package imports
    optimizePackageImports: [
      '@radix-ui/react-dialog',
      '@radix-ui/react-dropdown-menu',
      '@radix-ui/react-select',
      '@radix-ui/react-tabs',
      'lucide-react',
    ],
  },
  
  // Headers for Telegram Mini App
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'ALLOWALL', // Allow Telegram to embed the app
          },
          {
            key: 'Content-Security-Policy',
            value: "frame-ancestors 'self' https://web.telegram.org https://t.me;",
          },
        ],
      },
    ]
  },
  
  // Redirects
  async redirects() {
    return [
      {
        source: '/',
        destination: '/telegram',
        permanent: false,
      },
    ]
  },
  
  // Webpack configuration
  webpack: (config, { isServer }) => {
    // Fix for Prisma
    if (isServer) {
      config.externals = ['@prisma/client', ...config.externals]
    }
    
    return config
  },
}

export default nextConfig