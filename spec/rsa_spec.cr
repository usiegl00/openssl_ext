require "./spec_helper"

require "spec"
require "../src/openssl_ext/pkey/rsa"

describe OpenSSL::PKey::RSA do
  describe "instantiating and generate a key" do
    it "can instantiate and generate for a given key size" do
      pkey = OpenSSL::PKey::RSA.new(512)
      pkey.private?.should be_true
      pkey.public?.should be_false

      pkey.public_key.public?.should be_true
    end

    it "can export to PEM format" do
      pkey = OpenSSL::PKey::RSA.new(512)
      pkey.private?.should be_true

      pem = pkey.to_pem
      is_empty = "-----BEGIN PRIVATE KEY-----\n-----END PRIVATE KEY-----\n" == pem

      pem.should contain("BEGIN PRIVATE KEY")
      is_empty.should be_false
    end

    it "can export to DER format" do
      pkey = OpenSSL::PKey::RSA.new(512)
      pkey.private?.should be_true
      pem = pkey.to_pem
      der = pkey.to_der

      pkey = OpenSSL::PKey::RSA.new(der)
      pkey.to_pem.should eq pem
      pkey.to_der.should eq der
    end

    it "can instantiate with a PEM encoded key" do
      pem = OpenSSL::PKey::RSA.new(1024).to_pem
      pkey = OpenSSL::PKey::RSA.new(pem)

      pkey.to_pem.should eq pem
    end

    it "can instantiate with a DER encoded key" do
      der = OpenSSL::PKey::RSA.new(1024).to_der
      pkey = OpenSSL::PKey::RSA.new(der)

      pkey.to_der.should eq der
    end

    it "can instantiate with a PEM encoded key and a passphrase" do
      # At present, cannot export with passphrase - for some unknown openssl error means it writes an empty pem
      # The following encrypted_pem has the passphrase 'test'
      encrypted_pem = "-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,ABD606CE6CAEC3F9

KffBt0WVDVMnzcCG2lzeHmTao0N4pO+hnbGRFzpdvRtJeBRTJVY7fpVQS8dKinO4
tQlnx/e8iMuxiiVAND8YOjKMCRFVmNyry64hWPpBq69KgvBNAgnPTppc2AwCY5ZQ
juZjzQMllq1hxOuvh1zt0qQHFRVCoWtbTxziedqhgPHFCoUKoMOB+GD4Rj+t5jYh
fg/qStG1/rZ4mrPKTwS3LCYbVxc9X/7XJQWQ7IHmkf2VRr8mk9XRAZ0GLJXyNeai
O5PBYt+fw2hi+00kRCbvEU83yYYoELteSLcoYcd7scYl73myOkYruDAZWu1YJnnt
areXUPidcE+qCRSiF7395Ri5aLxcmGSgRm/P6z/nm31+3t2ISlvJwm5G73uAJWii
XrnZQq2uWsIagRQlm+SHW21dDfDw5v1QKzLGC6vhpKI1dPYJPqcU6CB3mym9l+xB
FLMigVC+QdmtSoFvcBu711TXEhEiDmszZEDWQoiF1nVXk2h/t8V6CE4b8TcODlHi
gZC/oMCdYsmt3lePIcnudNHjCcYJPxV7KciChuI4i6IfPzZGLr94Q7doNwYD8TLj
8MIcSNzsuUowMORKOfcV+kPGivm9hZ5hkvLqVHYKxkWJiTl0sHmx8QG/Mm4JW+cf
kAK6rBib7m+r78eCRNPCh3nkW4mCE3R9z6QPBW//3FnTEqmTljK4Fa+uA59jpMOb
1iEcbf2vwv7jrRx/CEu1VmOgsptVm1dcTABl/cL17Qp4tR7JUaW8FJYbf6WDyHl2
7V/JgTownoEvqM38HpjZwF8kO1NckwSNdWCbDEpBbDR20cwMSWy79Q==
-----END RSA PRIVATE KEY-----"
      # pkey = OpenSSL::RSA.new(1024)
      # cipher = OpenSSL::Cipher.new "des"
      # cipher.random_key
      # cipher.random_iv
      # cipher.update("test")

      # encrypted_pem = pkey.to_pem(cipher, "test")

      decoded = OpenSSL::PKey::RSA.new(encrypted_pem, "test")

      not_encrypted = "-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQC5+5+xnWggxNnnmCSNbIwTQFjcyawcvmPupeXs10sfhUAHUxtm
T5zH3AI46JrRZN7KV5Ac5bQWzF9ZMPeHqmq5FBdYooIF8W7lVtYx23OQX5vjFRN0
LRY8hyOKL07Us+aUeMwDXX7M6o58XO4bqOh8pGOqFLscCAkdAP9lDgeDGwIDAQAB
AoGAcRt/jnSNbEhrwXZ83GmkctzSbkxUWRLNEclhIP36WQwf2ZSIeFt4nO/Hhjao
WSqAeAxyv7BPKwJWBpdKIv7Ycfbu2c1JxWgacuotewMk5IYPXUs89QY3AL5I4BJd
Zqd3o9K4OWwakukkfjxHKFC/grifNa4yVQ6IZn+XuW/AspkCQQDlmzkUapzg0n0t
3gmK6KQD9f5YdXKYGYzYO3Scrtrz53fewqfDXdLC7TGL9qw9vGEFvSE727vwR3X+
+DZ6RWYvAkEAz1yqUNnrPwzGx3JuINIXgfzGTq4gSf+xRjb5qDJUPnMt4I3PrPyV
pm34aUCgo26go2+itBGjzFDaJCOT4izi1QJAJq6E6kSf01yCzFRo5ScWYrhxtjNr
L+a2DMPPfIoUxxyK3FOM8eP/mulc/Ih9MhVnfxEC5VO6kNtpLKBihSzl7wJBAJrR
4eu5uJV7kZJqEmV41spbkyg9g6gcOxxkgWQeJ5302wT0fGD4uTbolnbnJMjBGTjN
adot7XDn0Ob4lTpiLv0CQQDkECppYQ4N0ecegg1xPVqf19fHo/WGHGuScjfUPTI/
k0LaJjYM2ycehinmuLHgY3qdDJgtEbt4WG5XNQzhyfaN
-----END RSA PRIVATE KEY-----"

      not_encrypted_pkey = OpenSSL::PKey::RSA.new(not_encrypted)
      decoded.to_pem.should eq not_encrypted_pkey.to_pem
    end

    it "can instantiate with a PEM encoded key and a passphrase multiple times with a byte slice" do
      # At present, cannot export with passphrase - for some unknown openssl error means it writes an empty pem
      # The following encrypted_pem has the passphrase 'test'
      500.times do |i|
        puts "Trying: #{i+1}"
      key = "88cd2108b5347d973cf39cdf9053d7dd42704876d8c9a9bd8e2d168259d3ddf7".hexbytes
        encrypted_pem = "-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-256-CTR,E03017C7E49696033757EB4217D7FF2B

rRAdqZFnQylZlE5oRMAcIjhVlm2oHDbIeB7oOczdB2dFLTr0IdMyGFV93/W/Ut/1
gK/Ogay2iwlB/VI9yfRPl8Y616auc/XnE4DViX+YGB6Y8uF2up67u+PKEsRCU6zs
dYxb3cVH6bdjxk/qEnSJ1akHg8Ht7313a98GHGhNyAgKjp+uUtcOsvuORpQf5gdk
bdqyFFwk6lCweUkPLUb5/1dTnn1fUSZq6vPF+kbfQa3yMS6fGNWezGohiDFeYa/1
x2F/ZdCOs8Bt7Q3+U/qw22a7o3KqTD885Q4/PYx4CzjU3bwwqZlKyf9V3jtUG+X2
JZ5PBA1EHCoxsUUpqdH6vFGSY//OtDQigcIKRpEtfcLYg+SLJtKb3x6ReWbpcMoT
Mm/eU+fvgTA9YarivUaFCwdxXKAxxEw/t4oihAK9TTmn5B3vXE72YGEOnUcJsUEo
2koW2Pmv2+4nPINQ+1jfQexf919+Ki5Cr9AgXcUUqdgNQrfATkGPEU26f9Uhrt5q
bzNqYpk5btSHVj3l8PJ0jDJC9eJAqxZhLmarKZHRoxW5geZvjrc8uFNLPxnyPNCL
tODMZWXTfdN5V2og/VWBiW2ItYZmsq9/9+qN1Dp55LyWSZYLfCNkJsC3fmosV/XM
b3Mu9lF21BDAsnZQ/l7i5vYoVWs6eKlm99zW8soArIQXARWGY25LS6kmAj9UBVZv
3gYiwsBy3WAe0FwVpyapn1YKjmMWs0VWb2JePx/tCYPFAu1EuSOM8achj12Jxehd
nOa94Kk2d2uN90QCOdLFsXmj90ZIVU1OqgU4Eceb27D4aQ==
-----END RSA PRIVATE KEY-----"
        # pkey = OpenSSL::RSA.new(1024)
        # cipher = OpenSSL::Cipher.new "des"
        # cipher.random_key
        # cipher.random_iv
        # cipher.update("test")

        # encrypted_pem = pkey.to_pem(cipher, "test")

        decoded = OpenSSL::PKey::RSA.new(encrypted_pem, key)

        not_encrypted = "-----BEGIN RSA PRIVATE KEY-----
MIICXgIBAAKBgQDKEcV691wjYrKkdC8hleFeQaSASrg+26U8vlRhEOqrc34U7PnB
1Fj9NFUHnbq3I+oh/4TwgpLAZY3NdhVdQOmSVQv3K/Zk4MxPpqY5sLBdmMkIl2Sa
YRTOcl7Pskr7r198c1ZgY+viu+54EcIHJTvuXppyol+lS0N3BavrET+iKQIDAQAB
AoGASWKk3qChFLTOfg035LGjFHEwhesc+K8aVnIlAM98+mFKQ91AY1V0MBjmXIq6
+bIQYOKEbDhvhXIcSqb84U4mxPjsnNuUejMNNNmWozpLhIxAjQaKLQg7VK2agPf0
6VvXXiWXW5V4zMM8clwp7xnuuN3Fi+qSjC6pRgA7qXdxKRECQQD93YCRaiEgE4pP
24IgbRm0dLzKENzL5UADiHB3oMH2kfzDrkPgNMTlhQTJRxKGlQPOau4bCbDo0hIu
O4G2T2s9AkEAy8TElOA/q7CQsPw06bYNpxLawdDxebCd5oxNEX4qhsp8vU+qBTNr
XYZQB5ZLR/N1AdlYXSV1id52PTQumEsxXQJBAOvfToHNthFzlmM0dOdj9yov/OlS
WZQo4R1nO/gqqY1LfyrhU7eR0A/hU90f6BqbgfncaHc+vdzUsoe6Sn71s5ECQQCX
42UxH/L19Jf2BRkf+J82oXxEqo3Eypz4pC4yUtw6Oyc+KeqvE8P9I8f1z9bvnA7k
wPD4BZsWmKeEOahdxvbVAkEA4L7UshRCK5kOAYg8jPIh1Rb2S/YT1r+jg1f5rq9z
ZSAtGmS4BvaK7TIEKRZH4mgkmCzFpt/K2kJnEjDab2Px4Q==
-----END RSA PRIVATE KEY-----"

        not_encrypted_pkey = OpenSSL::PKey::RSA.new(not_encrypted)
        decoded.to_pem.should eq not_encrypted_pkey.to_pem
      end
    end
  end

  describe "RSA-blinding" do
    it "can turn blinding on" do
      rsa = OpenSSL::PKey::RSA.new(512)
      rsa.blinding_on!

      rsa.blinding_on?.should be_true
    end

    it "can turn blinding off" do
      rsa = OpenSSL::PKey::RSA.new(512)
      rsa.blinding_on!
      rsa.blinding_off!

      rsa.blinding_on?.should be_false
    end
  end

  describe "encrypting / decrypting" do
    it "can encrypt a string using its private key and decrypt with public key" do
      rsa = OpenSSL::PKey::RSA.new(512)
      encrypted = rsa.private_encrypt "hello world"
      decrypted = rsa.public_decrypt encrypted

      String.new(decrypted).should eq "hello world"
    end

    it "can encrypt a string using its public key and decrypt with private key" do
      rsa = OpenSSL::PKey::RSA.new(512)
      encrypted = rsa.public_encrypt "hello world"
      decrypted = rsa.private_decrypt encrypted

      String.new(decrypted).should eq "hello world"
    end

    it "should be able to sign and verify data" do
      rsa = OpenSSL::PKey::RSA.new(1024)
      digest = OpenSSL::Digest.new("sha256")
      data = "my test data"

      signature = rsa.sign(digest, data)
      new_digest = OpenSSL::Digest.new("sha256")

      rsa.verify(new_digest, signature, data).should be_true
      rsa.verify(new_digest, signature[0, 10], data).should be_false
    end
  end

  describe "can set parameters for more efficient decryption" do
    it "can set dmp1, dmq1, iqmp" do
    end

    it "can set p and q" do
    end

    it "can set n, e and d for key" do
    end
  end

  it "can instantiate from public key PEM string" do
    x509 = OpenSSL::X509::Certificate.new "-----BEGIN CERTIFICATE-----\nMIIDHDCCAgSgAwIBAgIIa9VSmwIf5zwwDQYJKoZIhvcNAQEFBQAwMTEvMC0GA1UE\nAxMmc2VjdXJldG9rZW4uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20wHhcNMTgw\nMzA3MjExOTQ4WhcNMTgwMzI0MDkzNDQ4WjAxMS8wLQYDVQQDEyZzZWN1cmV0b2tl\nbi5zeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbTCCASIwDQYJKoZIhvcNAQEBBQAD\nggEPADCCAQoCggEBAN1sDxP8oTHQ/5qz/S+QJB1iYLWgZYEFsUQnPyr+mtppI9yr\naS1p1WS5k5I6ygx4Mzoe5y+LUSUEgHyg6VEF+Iojm4vlBfWplovd+7Z39r5Meelt\nzN77EzexDQ1g5c/kZjNHgLaCXewMtqYi8oDb30GHl7aWT5eA680E2d0gJH8Rrtxw\nTegk/ZmRWAzLoBP5mMIr+tH9a83UBua90srBqHFRO7TIXf+B28ltC7UfPdyuQy+Q\n2hzi68y3wuTGEu4yJd7I98J0en4kFv/VhLVZo4cennR/ISP63XqtbdIBvG/ipdIR\nlOfO4MyPl0vRziKCx+KVjHxD989Mtcs3M/kXOdkCAwEAAaM4MDYwDAYDVR0TAQH/\nBAIwADAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwIwDQYJ\nKoZIhvcNAQEFBQADggEBAG03Jq/sWdGVG166NmQxcQTtYZCDh9KIQhVMR0v4K6sZ\n0UeUKcoICzyIk0gM0veyVw6lPRSsZthx3oylo7WeDzXVQ72FZVdg8MTi2H9gLFtJ\nJ81rwbGX/Sl5vKN25iPJrW+nzMJYB8wVQplOi94okmJWoBm573DRk2fXukJ93JS4\nb6xz1DQ6Axc6bC3azjSCCWzrx2iT2hyysnqqf2rngCjwSNVACU9xTS1XW40c590w\n9QTV6a885CiUWd4j4dRBwzs0tzvVM9Iwj+bCs6FkB4XrL2+d/sHiFHOF6VsMx7bI\nV1eRIDmhte6pPnDGMz9H/gHk4zGrs6qAxATDuwIIKMc=\n-----END CERTIFICATE-----\n"
    pem = x509.public_key.to_pem

    OpenSSL::PKey::RSA.new(pem).to_pem.should eq pem
  end
end
