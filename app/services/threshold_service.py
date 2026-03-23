from datetime import datetime, timezone

from app.db.sqlite import get_connection
import app.core.threshold_cache as threshold_cache


def load_thresholds() -> None:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        SELECT temp_min, temp_max, humidity_min, humidity_max
        FROM thresholds
        WHERE id = 1
        """
    )
    row = cursor.fetchone()

    if row is None:
        cursor.execute(
            """
            INSERT INTO thresholds (
                id, temp_min, temp_max, humidity_min, humidity_max, updated_at
            )
            VALUES (1, 18.0, 30.0, 40.0, 70.0, ?)
            """,
            (datetime.now(timezone.utc).isoformat(),),
        )
        conn.commit()

        threshold_cache.THRESHOLDS = {
            "temp_min": 18.0,
            "temp_max": 30.0,
            "humidity_min": 40.0,
            "humidity_max": 70.0,
        }
    else:
        threshold_cache.THRESHOLDS = {
            "temp_min": row[0],
            "temp_max": row[1],
            "humidity_min": row[2],
            "humidity_max": row[3],
        }

    conn.close()


def update_thresholds(
    *,
    temp_min: float,
    temp_max: float,
    humidity_min: float,
    humidity_max: float,
) -> None:
    if temp_min >= temp_max:
        raise ValueError("temp_min must be less than temp_max")

    if humidity_min >= humidity_max:
        raise ValueError("humidity_min must be less than humidity_max")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        UPDATE thresholds
        SET
            temp_min = ?,
            temp_max = ?,
            humidity_min = ?,
            humidity_max = ?,
            updated_at = ?
        WHERE id = 1
        """,
        (
            temp_min,
            temp_max,
            humidity_min,
            humidity_max,
            datetime.now(timezone.utc).isoformat(),
        ),
    )

    conn.commit()
    conn.close()

    # write-through cache
    threshold_cache.THRESHOLDS = {
        "temp_min": temp_min,
        "temp_max": temp_max,
        "humidity_min": humidity_min,
        "humidity_max": humidity_max,
    }


def get_thresholds() -> dict:
    if threshold_cache.THRESHOLDS is None:
        raise RuntimeError("Threshold cache not initialized")

    return threshold_cache.THRESHOLDS