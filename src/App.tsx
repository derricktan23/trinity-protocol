import { lazy, Suspense } from 'react'
import { Navigate, Route, Routes } from 'react-router-dom'
import { LayoutProvider } from './layouts'
import './style/main.css'
import { Backdrop } from '#components/Backdrop'
import { QueryClient, QueryClientProvider } from 'react-query'

const LazyDashboard = lazy(() => import('#pages/Dashboard'))
const LazyMarkets = lazy(() => import('#pages/Markets'))
const LazyAccess = lazy(() => import('#pages/Access'))
const LazyRecords = lazy(() => import('#pages/Records'))
const LazyNotFound = lazy(() => import('#pages/NotFound'))
import { Mainnet,ChainId , DAppProvider} from "@usedapp/core";

const queryClient = new QueryClient({})

function App() {
  return (

    <QueryClientProvider client={queryClient}>
      <DAppProvider
      config={{
        supportedChains: [ChainId.Kovan, ChainId.Rinkeby],
      }}
    >
        <LayoutProvider>
          <Suspense fallback={<Backdrop />}>
            <Routes>
              <Route path="/markets" element={<LazyMarkets />} />
              <Route path="/dashboard" element={<LazyDashboard />} />
              <Route path="/access" element={<LazyAccess />} />
              <Route path="/records" element={<LazyRecords />} />
              <Route path="/not-found" element={<LazyNotFound />} />
              <Route path="/" element={<Navigate to="markets" />} />
              <Route path="*" element={<Navigate to="not-found" />} />
            </Routes>
          </Suspense>
        </LayoutProvider>
      </DAppProvider>

    </QueryClientProvider>

  )
}

export default App
