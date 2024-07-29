// Import necessary modules
const express = require('express');
const mysql = require('mysql2');
const path = require('path');
const multer = require('multer');
const bcrypt = require('bcryptjs');
const session = require('express-session');

const app = express();

// Set up view engine
app.set('view engine', 'ejs');

// Enable static files
app.use(express.static('public'));

// Enable form processing
app.use(express.urlencoded({ extended: true }));

app.use(session({
    secret: 'helloworld', // Replace with a strong secret key
    resave: false,
    saveUninitialized: true
}));

const checkAuth = (req, res, next) => {
    if (req.session.userId) {
        next();
    } else {
        res.redirect('/login');
    }
};

// Create MySQL connection
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'instafit'
});

connection.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL:', err);
        return;
    }
    console.log('Connected to MySQL database');
});

// Set up multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'public/images'); // Directory to save images
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname); // Save image with original name
    }
});

const upload = multer({ storage: storage });

// Registration route
app.get('/register', (req, res) => {
    res.render('register');
});

app.post('/register', (req, res) => {
    const { username, email, password, bio } = req.body;

    // Check if any field is missing
    if (!username || !email || !password || !bio) {
        console.error('Missing fields in registration form');
        return res.status(400).send('All fields are required');
    }

    // Hash the password
    const hashedPassword = bcrypt.hashSync(password, 10);

    // Prepare SQL statement
    const sqlInsertUser = 'INSERT INTO users (username, email, password, bio) VALUES (?, ?, ?, ?)';
    const values = [username, email, hashedPassword, bio];

    // Log the values to be inserted
    console.log('Registering user with values:', values);

    // Execute SQL query
    connection.query(sqlInsertUser, values, (error, results) => {
        if (error) {
            console.error('Error registering user:', error);
            return res.status(500).send('Error registering user');
        }
        res.redirect('/login');
    });
});


// Login route
app.get('/login', (req, res) => {
    res.render('login');
});

app.post('/login', (req, res) => {
    const { email, password } = req.body;

    const sqlGetUser = 'SELECT * FROM users WHERE email = ?';
    connection.query(sqlGetUser, [email], (error, results) => {
        if (error) {
            console.error('Error logging in:', error);
            return res.status(500).send('Error logging in');
        }

        if (results.length > 0) {
            const user = results[0];
            const passwordMatch = bcrypt.compareSync(password, user.password);
            if (passwordMatch) {
                req.session.userId = user.user_id;
                req.session.username = user.username;
                res.redirect('/profile');
            } else {
                res.status(401).send('Incorrect password');
            }
        } else {
            res.status(404).send('User not found');
        }
    });
});

// Logout route
app.get('/logout', (req, res) => {
    req.session.destroy();
    res.redirect('/login');
});

app.get('/', (req, res) => {
    const query = `
        SELECT posts.*, users.username, users.profile_image 
        FROM posts 
        JOIN users ON posts.user_id = users.user_id
    `;
    connection.query(query, (error, results) => {
        if (error) throw error;
        res.render('index', { posts: results }); // Render HTML page with data
    });
});

app.get('/search', (req, res) => {
    const searchQuery = req.query.query;
    const searchSql = 'SELECT user_id, username, profile_image FROM users WHERE username LIKE ?';

    connection.query(searchSql, [`%${searchQuery}%`], (error, results) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error retrieving search results');
        }

        res.render('searchResults', { searchQuery, results });
    });
});


app.get('/profile', checkAuth, (req, res) => {
    const userId = req.session.userId; // Use the logged-in user's ID
    const getUserSql = 'SELECT * FROM users WHERE user_id = ?';
    const getPostsSql = 'SELECT * FROM posts WHERE user_id = ?';
    const getCommunitiesSql = `
        SELECT c.*
        FROM community c
        JOIN user_community uc ON c.communityID = uc.communityID
        WHERE uc.user_id = ?
    `;
    const getMentorsSql = `
        SELECT m.*, u.username AS name
        FROM mentors m
        JOIN users u ON m.user_id = u.user_id
        JOIN mentorship ms ON m.mentor_id = ms.mentor_id
        WHERE ms.mentee_id = ?
    `;

    connection.query(getUserSql, [userId], (error, userResults) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error retrieving user profile');
        }

        if (userResults.length > 0) {
            const user = userResults[0];

            // Fetch user's posts
            connection.query(getPostsSql, [userId], (postError, postResults) => {
                if (postError) {
                    console.error('Database query error:', postError.message);
                    return res.status(500).send('Error retrieving user posts');
                }

                // Fetch user's communities
                connection.query(getCommunitiesSql, [userId], (communityError, communityResults) => {
                    if (communityError) {
                        console.error('Database query error:', communityError.message);
                        return res.status(500).send('Error retrieving user communities');
                    }

                    // Fetch user's mentors with names
                    connection.query(getMentorsSql, [userId], (mentorError, mentorResults) => {
                        if (mentorError) {
                            console.error('Database query error:', mentorError.message);
                            return res.status(500).send('Error retrieving user mentors');
                        }

                        res.render('profile', {
                            user: user,
                            posts: postResults,
                            communities: communityResults,
                            mentors: mentorResults
                        });
                    });
                });
            });
        } else {
            res.status(404).send('User not found');
        }
    });
});


// Route to handle profile updates
app.post('/profile/update', checkAuth, upload.single('profile_image'), (req, res) => {
    const userId = req.session.userId; // Get logged-in user's ID from session
    const { username, bio } = req.body;
    let profileImage = '';

    if (req.file) {
        profileImage = req.file.filename; // Use uploaded filename if file exists
    }

    const updateSql = 'UPDATE users SET username = ?, bio = ?, profile_image = ? WHERE user_id = ?';

    connection.query(updateSql, [username, bio, profileImage, userId], (error, results) => {
        if (error) {
            console.error('Database update error:', error.message);
            return res.status(500).send('Error updating profile');
        }

        res.redirect('/profile');
    });
});


app.get('/users/:username', (req, res) => {
    const username = req.params.username;
    const getUserSql = 'SELECT * FROM users WHERE username = ?';
    const getPostsSql = 'SELECT * FROM posts WHERE user_id = ?';
    const getCommunitiesSql = `
        SELECT c.*
        FROM community c
        JOIN user_community uc ON c.communityID = uc.communityID
        WHERE uc.user_id = ?
    `;
    const getMentorsSql = `
        SELECT m.*
        FROM mentors m
        JOIN mentorship ms ON m.mentor_id = ms.mentor_id
        WHERE ms.mentee_id = ?
    `;

    connection.query(getUserSql, [username], (error, userResults) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error retrieving user profile');
        }

        if (userResults.length > 0) {
            const user = userResults[0];
            const userId = user.user_id;

            connection.query(getPostsSql, [userId], (postError, postResults) => {
                if (postError) {
                    console.error('Database query error:', postError.message);
                    return res.status(500).send('Error retrieving user posts');
                }

                connection.query(getCommunitiesSql, [userId], (communityError, communityResults) => {
                    if (communityError) {
                        console.error('Database query error:', communityError.message);
                        return res.status(500).send('Error retrieving user communities');
                    }

                    connection.query(getMentorsSql, [userId], (mentorError, mentorResults) => {
                        if (mentorError) {
                            console.error('Database query error:', mentorError.message);
                            return res.status(500).send('Error retrieving user mentors');
                        }

                        res.render('profile', {
                            user: user,
                            posts: postResults,
                            communities: communityResults,
                            mentors: mentorResults
                        });
                    });
                });
            });
        } else {
            res.status(404).send('User not found');
        }
    });
});

app.get('/upload', checkAuth, (req, res) => {
    res.render('upload');
});

app.post('/upload', checkAuth, upload.single('image'), (req, res) => {
    const userId = req.session.userId; // Use the logged-in user's ID
    const title = req.body.title;
    const description = req.body.description;
    const image = req.file.filename;
    const date = new Date();

    const sqlInsert = 'INSERT INTO posts (user_id, title, description, image, date) VALUES (?, ?, ?, ?, ?)';
    connection.query(sqlInsert, [userId, title, description, image, date], (error, results) => {
        if (error) {
            console.error("Error uploading:", error);
            return res.status(500).send('Error uploading');
        } else {
            res.redirect('/');
        }
    });
});

app.get('/community', checkAuth, (req, res) => {
    const userId = req.session.userId;

    const allCommunitiesSql = 'SELECT * FROM community';
    const joinedCommunitiesSql = `
        SELECT c.*
        FROM community c
        JOIN user_community uc ON c.communityID = uc.communityID
        WHERE uc.user_id = ?
    `;

    connection.query(allCommunitiesSql, (allError, allResults) => {
        if (allError) {
            console.error('Database query error:', allError.message);
            return res.status(500).send('Error retrieving communities');
        }

        connection.query(joinedCommunitiesSql, [userId], (joinedError, joinedResults) => {
            if (joinedError) {
                console.error('Database query error:', joinedError.message);
                return res.status(500).send('Error retrieving joined communities');
            }

            res.render('communities', { communities: allResults, joinedCommunities: joinedResults });
        });
    });
});

app.get('/community/:communityID', checkAuth, (req, res) => {
    const communityID = req.params.communityID;
    const userId = req.session.userId;

    const communitySql = 'SELECT * FROM community WHERE communityID = ?';
    const eventsSql = 'SELECT * FROM events WHERE communityID = ?';
    const leaderboardSql = 'SELECT * FROM leaderboard WHERE communityID = ?';
    const featuredCommunitiesSql = 'SELECT * FROM community WHERE featured = 1';

    connection.query(communitySql, [communityID], (error, communityResults) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error retrieving community');
        }

        if (communityResults.length > 0) {
            const community = communityResults[0];

            connection.query(eventsSql, [communityID], (eventsError, eventsResults) => {
                if (eventsError) {
                    console.error('Database query error:', eventsError.message);
                    return res.status(500).send('Error retrieving events');
                }

                connection.query(leaderboardSql, [communityID], (leaderboardError, leaderboardResults) => {
                    if (leaderboardError) {
                        console.error('Database query error:', leaderboardError.message);
                        return res.status(500).send('Error retrieving leaderboard');
                    }

                    connection.query(featuredCommunitiesSql, (featuredError, featuredResults) => {
                        if (featuredError) {
                            console.error('Database query error:', featuredError.message);
                            return res.status(500).send('Error retrieving featured communities');
                        }

                        // Render community details page with all fetched data
                        community.events = eventsResults;
                        community.leaderboard = leaderboardResults;

                        res.render('communityDetails', {
                            community: community,
                            featuredCommunities: featuredResults
                        });
                    });
                });
            });
        } else {
            res.status(404).send('Community not found');
        }
    });
});

app.get('/community/:communityID/join', checkAuth, (req, res) => {
    const communityID = req.params.communityID;

    const sql = 'SELECT * FROM community WHERE communityID = ?';
    connection.query(sql, [communityID], (error, results) => {
        if (error) {
            console.error('Error querying database:', error);
            return res.status(500).send('Error retrieving community');
        }
        if (results.length > 0) {
            const community = results[0];
            res.render('communityJoin', { community: community });
        } else {
            res.status(404).send('Community not found');
        }
    });
});

app.post('/community/join', checkAuth, (req, res) => {
    const userId = req.session.userId;
    const communityID = req.body.communityID;

    const joinCommunitySql = 'INSERT INTO user_community (user_id, communityID) VALUES (?, ?)';

    connection.query(joinCommunitySql, [userId, communityID], (error, results) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error joining community');
        }

        res.redirect('/community/' + communityID);
    });
});

app.get('/goal-setting', checkAuth, (req, res) => {
    const userId = req.session.userId; // Use the logged-in user's ID
    const getUserGoals = 'SELECT * FROM goal_setting WHERE user_id = ?';

    connection.query(getUserGoals, [userId], (error, goalResults) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error retrieving user goals');
        }

        res.render('goal-setting', {
            goals: goalResults
        });
    });
});

// Route to handle leaving a community
app.post('/community/leave/:communityID', checkAuth, (req, res) => {
    const communityID = req.params.communityID;
    const userId = req.session.userId;

    const leaveCommunitySql = 'DELETE FROM user_community WHERE user_id = ? AND communityID = ?';

    connection.query(leaveCommunitySql, [userId, communityID], (error, results) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error leaving community');
        }
        res.redirect('/profile');
    });
});

// Route to handle ending mentorship
app.post('/mentorship/end/:mentor_id', checkAuth, (req, res) => {
    const mentor_id = req.params.mentor_id;
    const mentee_id = req.session.userId;

    const endMentorshipSql = 'DELETE FROM mentorship WHERE mentor_id = ? AND mentee_id = ?';

    connection.query(endMentorshipSql, [mentor_id, mentee_id], (error, results) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error ending mentorship');
        }
        res.redirect('/profile');
    });
});


// Profile editing route
app.get('/edit-profile', checkAuth, (req, res) => {
    const userId = req.session.userId;

    const getUserSql = 'SELECT * FROM users WHERE user_id = ?';
    connection.query(getUserSql, [userId], (error, userResults) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error retrieving user profile');
        }

        if (userResults.length > 0) {
            const user = userResults[0];
            res.render('edit-profile', { user: user });
        } else {
            res.status(404).send('User not found');
        }
    });
});

app.get('/profile/edit', checkAuth, (req, res) => {
    const userId = req.session.userId;

    // Query to get user data
    const userSql = 'SELECT * FROM users WHERE user_id = ?';
    // Query to get mentorship data
    const mentorshipSql = 'SELECT * FROM mentorship WHERE mentee_id = ?';
    // (Include other queries for progress tracking and goal setting if needed)

    connection.query(userSql, [userId], (userError, userResults) => {
        if (userError) {
            console.error('Database query error:', userError.message);
            return res.status(500).send('Error retrieving user profile');
        }

        if (userResults.length > 0) {
            const user = userResults[0];

            connection.query(mentorshipSql, [userId], (mentorshipError, mentorshipResults) => {
                if (mentorshipError) {
                    console.error('Database query error:', mentorshipError.message);
                    return res.status(500).send('Error retrieving mentorship data');
                }

                const mentorship = mentorshipResults.length > 0 ? mentorshipResults[0] : {};

                // (Fetch progress tracking and goal setting data similarly if needed)

                res.render('editprofile', { 
                    user: user, 
                    mentorship: mentorship 
                    // Include other fetched data as well
                });
            });
        } else {
            res.status(404).send('User not found');
        }
    });
});


app.post('/edit-profile', checkAuth, upload.single('profile_image'), (req, res) => {
    const userId = req.session.userId;
    const { username, email, bio, currentProfileImage } = req.body;
    const profileImage = req.file ? req.file.filename : currentProfileImage;

    const updateUserSql = `
        UPDATE users 
        SET username = ?, email = ?, bio = ?, profile_image = ?
        WHERE user_id = ?
    `;

    connection.query(updateUserSql, [username, email, bio, profileImage, userId], (error, results) => {
        if (error) {
            console.error('Database update error:', error.message);
            return res.status(500).send('Error updating user profile');
        }

        res.redirect('/profile');
    });
});



// Route to display mentor details
app.get('/mentor/:mentor_id', checkAuth, (req, res) => {
    const mentorId = req.params.mentor_id;
    const getMentorSql = `
        SELECT m.*, u.username AS name
        FROM mentors m
        JOIN users u ON m.user_id = u.user_id
        WHERE m.mentor_id = ?
    `;

    connection.query(getMentorSql, [mentorId], (error, mentorResults) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error retrieving mentor details');
        }

        if (mentorResults.length > 0) {
            const mentor = mentorResults[0];
            res.render('mentorDetails', { mentor: mentor });
        } else {
            res.status(404).send('Mentor not found');
        }
    });
});



app.get('/mentoring', checkAuth, (req, res) => {
    const userId = req.session.userId;

    const getMentorsSql = `
        SELECT users.username, mentors.*
        FROM mentors
        JOIN users ON mentors.user_id = users.user_id
    `;
    const getRequestsSql = `
        SELECT mentee_requests.*, mentors.user_id AS mentor_user_id, users.username AS mentor_username
        FROM mentee_requests
        JOIN mentors ON mentee_requests.mentor_id = mentors.mentor_id
        JOIN users ON mentors.user_id = users.user_id
        WHERE mentee_requests.mentee_id = ?
    `;

    connection.query(getMentorsSql, (mentorError, mentorResults) => {
        if (mentorError) {
            console.error('Database query error:', mentorError.message);
            return res.status(500).send('Error retrieving mentors');
        }

        connection.query(getRequestsSql, [userId], (requestError, requestResults) => {
            if (requestError) {
                console.error('Database query error:', requestError.message);
                return res.status(500).send('Error retrieving mentorship requests');
            }

            res.render('mentoring', {
                mentors: mentorResults,
                requests: requestResults
            });
        });
    });
});

app.get('/mentoring/request/:mentor_id', checkAuth, (req, res) => {
    const mentor_id = req.params.mentor_id;
    const userId = req.session.userId;

    const sqlInsertRequest = `
        INSERT INTO mentee_requests (mentee_id, mentor_id)
        VALUES (?, ?)
    `;

    connection.query(sqlInsertRequest, [userId, mentor_id], (error, results) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error requesting mentorship');
        }

        res.redirect('/mentoring');
    });
});

app.post('/mentoring/cancel', checkAuth, (req, res) => {
    const requestId = req.body.request_id;
    const userId = req.session.userId;

    const cancelRequestSql = 'DELETE FROM mentee_requests WHERE request_id = ? AND mentee_id = ?';

    connection.query(cancelRequestSql, [requestId, userId], (error, results) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error canceling request');
        }

        res.redirect('/mentoring');
    });
});


// Handle post deletion
app.post('/posts/delete/:id', checkAuth, (req, res) => {
    const postId = req.params.id;
    const userId = req.session.userId;

    // Verify if the post belongs to the logged-in user
    const verifyPostSql = 'SELECT * FROM posts WHERE post_id = ? AND user_id = ?';
    connection.query(verifyPostSql, [postId, userId], (error, results) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error deleting post');
        }

        if (results.length === 0) {
            return res.status(403).send('Unauthorized to delete this post');
        }

        // Delete post from database
        const deletePostSql = 'DELETE FROM posts WHERE post_id = ?';
        connection.query(deletePostSql, [postId], (deleteError, deleteResults) => {
            if (deleteError) {
                console.error('Database query error:', deleteError.message);
                return res.status(500).send('Error deleting post');
            }

            res.redirect('/profile'); // Redirect back to profile after deletion
        });
    });
});

app.get('/contact', (req, res) => {
    res.render('contact');
});

app.post('/contact', (req, res) => {
    const { name, email, message } = req.body;
    const contactSql = 'INSERT INTO contact (name, email, message) VALUES (?, ?, ?)';
    
    connection.query(contactSql, [name, email, message], (error, results) => {
        if (error) {
            console.error('Database query error:', error.message);
            return res.status(500).send('Error submitting contact form');
        }
        res.redirect('/contact-success');
    });
});

app.get('/contact-success', (req, res) => {
    res.send('Thank you for contacting us! I will get back to you shortly.');
});

const port = 3000;
app.listen(port, () => {
    console.log(`Server running on port http://localhost:${port}`);
});