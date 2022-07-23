import { Avatar, Box, Button, Flex,  useColorModeValue, VStack, FlexProps} from '@chakra-ui/react'
import { useEffect,useState } from 'react';
import {useEtherBalance, useEthers , shortenAddress, useLookupAddress } from '@usedapp/core'
import { AccountModal } from './AccountModal'
import { Colors } from './styles'
import styled from 'styled-components'

interface NavigationProps extends FlexProps {
  onOpen: () => void
}

export const NavigationWithConnected = ({ onOpen, ...rest }: NavigationProps) =>{
  const { account, deactivate, activateBrowserWallet } = useEthers()
  const { ens } = useLookupAddress(account)
  const [showModal, setShowModal] = useState(false)

  const [activateError, setActivateError] = useState('')
  const { error } = useEthers()
  useEffect(() => {
    if (error && account) {
      setActivateError(error.message)
      return
    }
    setActivateError('')
  }, [error, account])

  const activate = async () => {
    setActivateError('')
    activateBrowserWallet()
  }

  return (
    <Flex
      ml={{ base: 0, md: 60 }}
      px={{ base: 4, md: 4 }}
      height="16"
      alignItems="center"
      className="bg-white"
      borderBottomWidth="1px"
      borderBottomColor={useColorModeValue('gray.200', 'gray.700')}
      justifyContent={{ base: 'space-between', md: 'flex-end' }}
    >
    <Account>
      <ErrorWrapper>{activateError}</ErrorWrapper>
      {showModal && <AccountModal setShowModal={setShowModal} />}
      {account ? (
        <>
          <AccountLabel onClick={() => setShowModal(!showModal)}>{ens ?? shortenAddress(account)}</AccountLabel>

          <LoginButton onClick={() => deactivate()}>Disconnect</LoginButton>
        </>
      ) : (
        <LoginButton onClick={activate}>Connect</LoginButton>
      )}
    </Account>

    </Flex>
  )
}
const ErrorWrapper = styled.div`
  color: #ff3960;
  margin-right: 40px;
  margin-left: 40px;
  overflow: auto;
`

const Account = styled.div`
  display: flex;
  align-items: center;
    margin-left: 40px;

`

const LoginButton = styled(Button)`
  background-color: ${Colors.Yellow[100]};
  
`

const AccountLabel = styled(Button)`
  height: 32px;
  margin-right: 40px;
  padding-right: 40px;
  padding-left: 8px;
  background-color: ${Colors.Yellow[100]};
  font-size: 12px;
`