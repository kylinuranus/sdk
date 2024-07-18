//
//  ecdh.h
//  KostalBleSDK
//
//  Created by shudingcai on 29/05/2018.
//  Copyright © 2018 shudingcai. All rights reserved.
//

#ifndef ecdh_h
#define ecdh_h

#include <stdio.h>


/* for size-annotated integer types: uint8_t, uint32_t etc. */
#include <stdint.h>

#define NIST_B163  1
#define NIST_K163  2
#define NIST_B233  3
#define NIST_K233  4
#define NIST_B283  5
#define NIST_K283  6
#define NIST_B409  7
#define NIST_K409  8 /* currently defunct :( */
#define NIST_B571  9
#define NIST_K571 10 /* also not working...  */

/* What is the default curve to use? */
#ifndef ECC_CURVE
#define ECC_CURVE NIST_B163
#endif

#if defined(ECC_CURVE) && (ECC_CURVE != 0)
#if   (ECC_CURVE == NIST_K163) || (ECC_CURVE == NIST_B163)
#define CURVE_DEGREE       163
#define ECC_PRV_KEY_SIZE   21
#elif (ECC_CURVE == NIST_K233) || (ECC_CURVE == NIST_B233)
#define CURVE_DEGREE       233
#define ECC_PRV_KEY_SIZE   30
#elif (ECC_CURVE == NIST_K283) || (ECC_CURVE == NIST_B283)
#define CURVE_DEGREE       283
#define ECC_PRV_KEY_SIZE   36
#elif (ECC_CURVE == NIST_K409) || (ECC_CURVE == NIST_B409)
#define CURVE_DEGREE       409
#define ECC_PRV_KEY_SIZE   52
#elif (ECC_CURVE == NIST_K571) || (ECC_CURVE == NIST_B571)
#define CURVE_DEGREE       571
#define ECC_PRV_KEY_SIZE   72
#endif
#else
#error Must define a curve to use
#endif

#define ECC_PUB_KEY_SIZE     (2 * ECC_PRV_KEY_SIZE)


/******************************************************************************/


/* NOTE: assumes private is filled with random data before calling */
int ecdh_generate_keys(uint8_t* public, uint8_t* private);

/* input: own private key + other party's public key, output: shared secret */
int ecdh_shared_secret(const uint8_t* private, const uint8_t* others_pub, uint8_t* output);


/* Broken :( .... */
int ecdsa_sign(const uint8_t* private, uint8_t* hash, uint8_t* random_k, uint8_t* signature);
int ecdsa_verify(const uint8_t* public, uint8_t* hash, const uint8_t* signature);


/******************************************************************************/




#endif /* ecdh_h */
