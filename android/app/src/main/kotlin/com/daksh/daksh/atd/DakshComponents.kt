package com.daksh.daksh.atd

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.daksh.daksh.R

@Composable
fun DakshLogo(
    modifier: Modifier = Modifier,
    logoSize: Dp = 64.dp,
    showTagline: Boolean = true
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Multi-color Fingerprint Logo Image
        Image(
            painter = painterResource(id = R.mipmap.ic_launcher_foreground),
            contentDescription = "DAKSH Logo",
            modifier = Modifier.size(logoSize)
        )

        Spacer(modifier = Modifier.height(6.dp))

        // DAKSH Title
        Text(
            text = "DAKSH",
            fontSize = (logoSize.value * 0.38f).sp,
            fontWeight = FontWeight.Black,
            color = Color(0xFF212121),
            letterSpacing = 3.sp,
            fontFamily = FontFamily.SansSerif
        )

        if (showTagline) {
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = "TRUST YOUR TOUCH",
                fontSize = (logoSize.value * 0.15f).sp,
                fontWeight = FontWeight.SemiBold,
                color = Color(0xFF757575),
                letterSpacing = 2.sp
            )
        }
    }
}

@Composable
fun DakshLogoHeader(
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier.fillMaxWidth(),
        color = Color.White,
        shadowElevation = 2.dp
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Image(
                    painter = painterResource(id = R.mipmap.ic_launcher_foreground),
                    contentDescription = "DAKSH Logo",
                    modifier = Modifier.size(38.dp)
                )
                Spacer(modifier = Modifier.width(10.dp))
                Column {
                    Text(
                        text = "DAKSH",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color = Color(0xFF1A1A1A),
                        letterSpacing = 1.5.sp
                    )
                    Text(
                        text = "TRUST YOUR TOUCH • PalmATD",
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFFE57373),
                        letterSpacing = 0.5.sp
                    )
                }
            }

            Surface(
                shape = RoundedCornerShape(12.dp),
                color = Color(0xFFE8F5E9)
            ) {
                Text(
                    text = "v2.0.0",
                    color = Color(0xFF2E7D32),
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                )
            }
        }
    }
}
